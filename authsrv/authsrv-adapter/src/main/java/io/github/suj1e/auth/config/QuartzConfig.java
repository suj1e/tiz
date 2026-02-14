package io.github.suj1e.auth.config;

import org.quartz.CronScheduleBuilder;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.SimpleScheduleBuilder;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

import javax.sql.DataSource;
import java.util.Properties;

import static io.github.suj1e.auth.adapter.infra.job.OutboxPublisherJob.JOB_NAME;
import static io.github.suj1e.auth.adapter.infra.job.RefreshTokenCleanupJob.REFRESH_TOKEN_CLEANUP_JOB;
import static io.github.suj1e.auth.adapter.infra.job.AccountUnlockJob.ACCOUNT_UNLOCK_JOB;

/**
 * Quartz configuration for scheduled tasks.
 *
 * <p>Configures Quartz with JDBC job store for clustering support.
 *
 * @author sujie
 */
@Configuration
public class QuartzConfig {

    @Value("${app.quartz.outbox-interval-seconds:10}")
    private int outboxIntervalSeconds;

    @Value("${app.quartz.token-cleanup-hour:2}")
    private int tokenCleanupHour;

    /**
     * Quartz scheduler factory bean with JDBC job store.
     */
    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(DataSource dataSource) {
        SchedulerFactoryBean factory = new SchedulerFactoryBean();

        // Use JDBC job store for clustering
        factory.setDataSource(dataSource);
        factory.setApplicationContextSchedulerContextKey("applicationContext");

        // Quartz properties
        Properties props = new Properties();

        // Main scheduler settings
        props.put("org.quartz.scheduler.instanceName", "authsrvScheduler");
        props.put("org.quartz.scheduler.instanceId", "AUTO");
        props.put("org.quartz.scheduler.skipUpdateCheck", "true");

        // Job store settings
        props.put("org.quartz.jobStore.class", "org.quartz.impl.jdbcjobstore.JobStoreTX");
        props.put("org.quartz.jobStore.driverDelegateClass", "org.quartz.impl.jdbcjobstore.StdJDBCDelegate");
        props.put("org.quartz.jobStore.tablePrefix", "QRTZ_");
        props.put("org.quartz.jobStore.isClustered", "true");
        props.put("org.quartz.jobStore.clusterCheckinInterval", "20000");
        props.put("org.quartz.jobStore.maxMisfiresToHandleAtATime", "10");
        props.put("org.quartz.jobStore.txIsolationLevelSerializable", "true");
        props.put("org.quartz.jobStore.selectWithLockSQL", "SELECT * FROM {0}LOCKS WITH UPDLOCK WHERE LOCK_NAME = ?");

        // Thread pool settings
        props.put("org.quartz.threadPool.class", "org.quartz.simpl.SimpleThreadPool");
        props.put("org.quartz.threadPool.threadCount", "5");
        props.put("org.quartz.threadPool.threadPriority", "5");
        props.put("org.quartz.threadPool.threadsInheritContextClassLoaderOfInitializingThread", "true");

        // Plugin settings
        props.put("org.quartz.plugin.triggHistory.class", "org.quartz.plugins.history.LoggingJobHistoryPlugin");
        props.put("org.quartz.plugin.triggHistory.triggerHistoryEnabled", "true");

        factory.setQuartzProperties(props);

        // Auto-start scheduler
        factory.setAutoStartup(true);
        factory.setStartupDelay(10);

        // Register jobs and triggers
        factory.setJobDetails(jobDetails());
        factory.setTriggers(triggers());

        return factory;
    }

    /**
     * Job details for all scheduled jobs.
     */
    @Bean
    public org.quartz.JobDetail[] jobDetails() {
        return new org.quartz.JobDetail[]{
            outboxPublisherJobDetail(),
            refreshTokenCleanupJobDetail(),
            accountUnlockJobDetail()
        };
    }

    /**
     * Triggers for all scheduled jobs.
     */
    @Bean
    public Trigger[] triggers() {
        return new Trigger[]{
            outboxPublisherTrigger(),
            refreshTokenCleanupTrigger(),
            accountUnlockTrigger()
        };
    }

    // ==================== Outbox Publisher Job ====================

    @Bean
    public JobDetail outboxPublisherJobDetail() {
        return JobBuilder.newJob()
            .ofType(io.github.suj1e.auth.adapter.infra.job.OutboxPublisherJob.class)
            .storeDurably(true)
            .withIdentity(JOB_NAME, "outbox-group")
            .withDescription("Publish pending outbox events to Kafka")
            .build();
    }

    @Bean
    public Trigger outboxPublisherTrigger() {
        SimpleScheduleBuilder schedule = SimpleScheduleBuilder.simpleSchedule()
            .withIntervalInSeconds(outboxIntervalSeconds)
            .repeatForever();

        return TriggerBuilder.newTrigger()
            .forJob(outboxPublisherJobDetail())
            .withIdentity("outbox-publisher-trigger", "outbox-group")
            .withDescription("Trigger for outbox publisher job")
            .withSchedule(schedule)
            .build();
    }

    // ==================== Refresh Token Cleanup Job ====================

    @Bean
    public JobDetail refreshTokenCleanupJobDetail() {
        return JobBuilder.newJob()
            .ofType(io.github.suj1e.auth.adapter.infra.job.RefreshTokenCleanupJob.class)
            .storeDurably(true)
            .withIdentity(REFRESH_TOKEN_CLEANUP_JOB, "cleanup-group")
            .withDescription("Clean up expired refresh tokens")
            .build();
    }

    @Bean
    public Trigger refreshTokenCleanupTrigger() {
        // Run daily at specified hour (default 2 AM)
        String cronExpression = String.format("0 0 %d * * ?", tokenCleanupHour);

        return TriggerBuilder.newTrigger()
            .forJob(refreshTokenCleanupJobDetail())
            .withIdentity("refresh-token-cleanup-trigger", "cleanup-group")
            .withDescription("Trigger for refresh token cleanup job")
            .withSchedule(CronScheduleBuilder.cronSchedule(cronExpression))
            .build();
    }

    // ==================== Account Unlock Job ====================

    @Bean
    public JobDetail accountUnlockJobDetail() {
        return JobBuilder.newJob()
            .ofType(io.github.suj1e.auth.adapter.infra.job.AccountUnlockJob.class)
            .storeDurably(true)
            .withIdentity(ACCOUNT_UNLOCK_JOB, "maintenance-group")
            .withDescription("Automatically unlock accounts with expired lock period")
            .build();
    }

    @Bean
    public Trigger accountUnlockTrigger() {
        // Run every 5 minutes
        SimpleScheduleBuilder schedule = SimpleScheduleBuilder.simpleSchedule()
            .withIntervalInMinutes(5)
            .repeatForever();

        return TriggerBuilder.newTrigger()
            .forJob(accountUnlockJobDetail())
            .withIdentity("account-unlock-trigger", "maintenance-group")
            .withDescription("Trigger for account unlock job")
            .withSchedule(schedule)
            .build();
    }
}
