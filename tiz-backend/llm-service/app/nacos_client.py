"""Nacos service discovery client."""

import logging
import socket

import nacos

from app.config import get_settings

logger = logging.getLogger(__name__)


class NacosClient:
    """Nacos service registration client."""

    def __init__(self) -> None:
        """Initialize Nacos client."""
        self._client = None
        self._service_name = None
        self._registered = False

    @property
    def client(self):
        """Get or create Nacos client."""
        if self._client is None:
            settings = get_settings()
            self._client = nacos.NacosClient(
                settings.nacos_server_addr,
                namespace=settings.nacos_namespace,
                username=settings.nacos_username,
                password=settings.nacos_password,
            )
        return self._client

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

    def register(self) -> None:
        """Register service to Nacos."""
        settings = get_settings()

        if not settings.nacos_enabled:
            logger.info("Nacos registration disabled")
            return

        try:
            self._service_name = settings.service_name
            ip = self._get_local_ip()
            port = settings.service_port

            self.client.add_naming_instance(
                self._service_name,
                ip,
                port,
                group_name="DEFAULT_GROUP",
                metadata={"version": "1.0.0", "type": "python"},
            )

            self._registered = True
            logger.info(f"Registered to Nacos: {self._service_name} @ {ip}:{port}")

        except Exception as e:
            logger.error(f"Failed to register to Nacos: {e}")

    def deregister(self) -> None:
        """Deregister service from Nacos."""
        if not self._registered:
            return

        try:
            ip = self._get_local_ip()
            port = get_settings().service_port

            self.client.remove_naming_instance(
                self._service_name,
                ip,
                port,
                group_name="DEFAULT_GROUP",
            )

            logger.info(f"Deregistered from Nacos: {self._service_name}")

        except Exception as e:
            logger.error(f"Failed to deregister from Nacos: {e}")


# Global Nacos client instance
nacos_client = NacosClient()
