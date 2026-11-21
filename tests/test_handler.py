import importlib.util
import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock, patch


class HandlerTest(unittest.TestCase):
    def setUp(self):
        self.s3 = Mock()
        self.rekognition = Mock()
        self.rekognition.recognize_celebrities.return_value = {
            "CelebrityFaces": [{"Name": "Example", "MatchConfidence": 99.0}]
        }
        clients = {"s3": self.s3, "rekognition": self.rekognition}
        boto3 = Mock()
        boto3.client.side_effect = clients.__getitem__
        with patch.dict(sys.modules, {"boto3": boto3}):
            spec = importlib.util.spec_from_file_location(
                "recognition_handler", Path(__file__).parents[1] / "src" / "handler.py"
            )
            self.handler = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(self.handler)

    def test_processes_all_records_and_preserves_prefixes(self):
        event = {
            "Records": [
                self.record("first/photo+%2B.jpg"),
                self.record("second/photo+%2B.jpg"),
            ]
        }
        with patch.dict(os.environ, {"OUT_BUCKET_NAME": "test-output"}):
            response = self.handler.lambda_handler(event, None)

        keys = ["results/first/photo +.jpg.json", "results/second/photo +.jpg.json"]
        self.assertEqual(keys, json.loads(response["body"])["output_keys"])
        self.assertEqual(2, self.rekognition.recognize_celebrities.call_count)
        self.rekognition.recognize_celebrities.assert_any_call(
            Image={"S3Object": {"Bucket": "test-input", "Name": "first/photo +.jpg"}}
        )
        writes = self.s3.put_object.call_args_list
        self.assertEqual(keys, [write.kwargs["Key"] for write in writes])
        self.assertEqual("test-output", writes[0].kwargs["Bucket"])
        self.assertEqual(
            [{"name": "Example", "match_confidence": 99.0}],
            json.loads(writes[0].kwargs["Body"])["celebrities"],
        )

    def test_empty_event_does_not_call_aws(self):
        self.assertEqual(400, self.handler.lambda_handler({}, None)["statusCode"])
        self.s3.put_object.assert_not_called()
        self.rekognition.recognize_celebrities.assert_not_called()

    def record(self, key):
        return {"s3": {"bucket": {"name": "test-input"}, "object": {"key": key}}}
