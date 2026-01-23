from dotenv import load_dotenv
from typing import Optional
from urllib.parse import urlparse
import os

load_dotenv()


class Settings:
	"""Simple settings container reading from environment variables."""

	def __init__(self) -> None:
		self.SECRET_KEY: str = os.getenv("SECRET_KEY", "change-me")
		self.ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
		self.ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

		# Database: either provide full DATABASE_URL or individual parts
		self.DATABASE_URL: Optional[str] = os.getenv("DATABASE_URL")
		self.DB_USER: Optional[str] = os.getenv("DB_USER")
		self.DB_PASSWORD: Optional[str] = os.getenv("DB_PASSWORD")
		self.DB_HOST: Optional[str] = os.getenv("DB_HOST")
		self.DB_PORT: Optional[str] = os.getenv("DB_PORT")
		self.DB_NAME: Optional[str] = os.getenv("DB_NAME")

		# parse DATABASE_URL into parts if present
		self.parse_database()

	def parse_database(self):
		if self.DATABASE_URL:
			parsed = urlparse(self.DATABASE_URL)
			if parsed.username:
				self.DB_USER = parsed.username
			if parsed.password:
				self.DB_PASSWORD = parsed.password
			if parsed.hostname:
				self.DB_HOST = parsed.hostname
			if parsed.port:
				self.DB_PORT = str(parsed.port)
			if parsed.path and len(parsed.path) > 1:
				self.DB_NAME = parsed.path.lstrip('/')


settings = Settings()
