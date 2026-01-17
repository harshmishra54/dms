import http from "k6/http";
import { SharedArray } from "k6/data";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3001";

// ✅ Read UUIDs from file (1 UUID per line)
const requestIds = new SharedArray("requestIds", function () {
  return open("./request_ids.txt")
    .split("\n")
    .map((x) => x.trim())
    .filter(Boolean);
});

export const options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      rate: 1000, // ✅ change to 5000 if needed
      timeUnit: "1s",
      duration: "30s",
      preAllocatedVUs: 200,
      maxVUs: 5000,
    },
  },
};

export default function () {
  const request_id = requestIds[Math.floor(Math.random() * requestIds.length)];

  const payload = JSON.stringify({
    role_id: "1",         // ✅ always 1 (string like your flutter model)
    request_id: request_id,
  });

  const res = http.post(`${BASE_URL}/common/credit-limit-list`, payload, {
    headers: {
      "Content-Type": "application/json",
      // add auth token if needed:
      // Authorization: `Bearer ${__ENV.TOKEN}`,
    },
  });

  // ✅ validation (optional but recommended)
  check(res, {
    "status is 200": (r) => r.status === 200,
    // "response not empty": (r) => r.body && r.body.length > 0,
  });
}
