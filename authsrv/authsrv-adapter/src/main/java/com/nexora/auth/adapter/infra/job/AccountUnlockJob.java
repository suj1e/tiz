package com.nexora.auth.adapter.infra.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.adapter.service.UserService;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import org.quartz.*;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Account unlock job.
 *
 * <p>Automatically unlocks user accounts whose lock period has expired.
 * This job runs every 5 minutes to check for accounts that should be unlocked.
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AccountUnlockJob implements Job {

    public static final String ACCOUNT_UNLOCK_JOB = "ACCOUNT_UNLOCK_JOB";

    private final UserRepository userRepository;
    private final UserService userService;

    @Override
    @Transactional
    public void execute(JobExecutionContext context) {
        log.debug("Starting account unlock job");

        // Find users with expired lock periods
        List<User> lockedUsers = userRepository.findUsersWithExpiredLocks();

        if (lockedUsers.isEmpty()) {
            log.debug("No accounts to unlock");
            return;
        }

        log.info("Found {} accounts with expired lock periods", lockedUsers.size());

        // Unlock each user (event publishing is handled by UserService)
        for (User user : lockedUsers) {
            user.unlock();
            user.resetFailedLoginAttempts();
            userRepository.save(user);

            log.info("Unlocked account: {}", user.getUsername());

            // Note: Event publishing is NOT done here to avoid duplicate events
            // The job is automated, so we don't need to publish ACCOUNT_UNLOCKED events
            // Events are only published for admin/user-initiated actions
        }

        log.info("Account unlock job completed: unlocked {} accounts", lockedUsers.size());
    }
}
