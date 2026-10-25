"""Mocked tests for raptor_api — no live network is used."""
import json
import os
import sys
import urllib.request
from unittest import mock

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from raptor_api import (  # noqa: E402
    NotImplementedLiveCall,
    RaptorApiClient,
    RaptorApiError,
    local_device_id,
    read_key_from_env_or_stdin,
)


class FakeResponse:
    def __init__(self, payload: dict):
        self._payload = json.dumps(payload).encode()

    def read(self):
        return self._payload

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


def test_local_device_id_is_stable_and_prefixed():
    assert local_device_id().startswith("local-")
    assert local_device_id() == local_device_id()


def test_http_base_url_rejected():
    with pytest.raises(RaptorApiError):
        RaptorApiClient(base_url="http://api.example.invalid")


def test_fetch_version_mocked():
    client = RaptorApiClient(base_url="https://api.example.invalid")
    payload = {"channel": "stable", "clientVersionUpload": "version-abc123", "version": "0.1.27"}
    with mock.patch.object(urllib.request, "urlopen", return_value=FakeResponse(payload)):
        info = client.fetch_version()
    assert info.channel == "stable"
    assert info.client_version_upload == "version-abc123"
    assert info.version == "0.1.27"


def test_fetch_version_without_base_url_is_stub():
    with pytest.raises(NotImplementedLiveCall):
        RaptorApiClient().fetch_version()


def test_activate_is_stub_and_rejects_bad_key():
    client = RaptorApiClient(base_url="https://api.example.invalid")
    with pytest.raises(RaptorApiError):
        client.activate("bad key with spaces")
    with pytest.raises(NotImplementedLiveCall):
        client.activate("VALIDKEY123")


def test_check_whitelist_is_stub():
    with pytest.raises(NotImplementedLiveCall):
        RaptorApiClient().check_whitelist("some-hwid")


def test_activation_request_uses_post_and_header_not_query():
    client = RaptorApiClient(base_url="https://api.example.invalid")
    request = client.activation_request("SECRETKEY")
    assert request.get_method() == "POST"
    assert "SECRETKEY" not in request.full_url
    assert "key=" not in request.full_url
    assert request.get_header("Authorization") == "Bearer SECRETKEY"


def test_read_key_from_env(monkeypatch):
    monkeypatch.setenv("RAPTOR_LICENSE_KEY", "ENVKEY123")
    assert read_key_from_env_or_stdin() == "ENVKEY123"
