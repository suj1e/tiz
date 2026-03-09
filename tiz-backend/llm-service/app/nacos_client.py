"""Nacos service discovery client."""

import asyncio
import logging
import socket

from v2.nacos import (
    NacosNamingService,
    ClientConfigBuilder,
    RegisterInstanceParam,
    DeregisterInstanceParam,
)

from app.config import get_settings

logger = logging.getLogger(__name__)


class NacosClient:
    """Nacos service registration client."""

    def __init__(self) -> None:
        """Initialize Nacos client."""
        self._naming_service = None
        self._service_name = None
        self._registered = False

    async def _get_naming_service(self):
        """Get or create Nacos naming service."""
        if self._naming_service is None:
            settings = get_settings()
            config = (
                ClientConfigBuilder()
                .server_address(settings.nacos_server_addr)
                .namespace(settings.nacos_namespace or "public")
                .username(settings.nacos_username or "")
                .password(settings.nacos_password or "")
                .build()
            )
            self._naming_service = NacosNamingService(config)
        return self._naming_service

    def _get_local_ip(self) -> str:
        """Get local IP address."""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return "127.0.0.1"

    async def register(self) -> None:
        """Register service to Nacos."""
        settings = get_settings()

        if not settings.nacos_enabled:
            logger.info("Nacos registration disabled")
            return

        try:
            self._service_name = settings.service_name
            ip = self._get_local_ip()
            port = settings.service_port

            naming_service = await self._get_naming_service()

            param = RegisterInstanceParam(
                service_name=self._service_name,
                ip=ip,
                port=port,
                group_name="DEFAULT_GROUP",
                metadata={"version": "1.0.0", "type": "python"},
            )

            await naming_service.register_instance(param)

            self._registered = True
            logger.info(f"Registered to Nacos: {self._service_name} @ {ip}:{port}")

        except Exception as e:
            logger.error(f"Failed to register to Nacos: {e}")

    async def deregister(self) -> None:
        """Deregister service from Nacos."""
        if not self._registered:
            return

        try:
            ip = self._get_local_ip()
            port = get_settings().service_port

            naming_service = await self._get_naming_service()

            param = DeregisterInstanceParam(
                service_name=self._service_name,
                ip=ip,
                port=port,
                group_name="DEFAULT_GROUP",
            )

            await naming_service.deregister_instance(param)

            logger.info(f"Deregistered from Nacos: {self._service_name}")

        except Exception as e:
            logger.error(f"Failed to deregister from Nacos: {e}")


# Global Nacos client instance
nacos_client = NacosClient()
