import http from "k6/http";
import { check } from "k6";

const BASE_URL = __ENV.BASE_URL || "http://localhost:3001";

export const options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      rate: 200, // ✅ start from 200 RPS (increase gradually)
      timeUnit: "1s",
      duration: "30s",
      preAllocatedVUs: 200,
      maxVUs: 2000,
    },
  },
};

// ✅ fixed values
const ZONE_ID = "23f0503a-1d5a-4060-a2b0-e0868c8947d2";
const TIME_KEY = "lastyear";

export default function () {
  const payload = JSON.stringify({
    zoneId: [ZONE_ID],
    timeKey: TIME_KEY,
  });

  const res = http.post(`${BASE_URL}/common/sales-Sales-Overview`, payload, {
    headers: {
      "Content-Type": "application/json",
      // Authorization: `Bearer ${__ENV.TOKEN}`, // ✅ add if needed
    },
  });

  check(res, {
    "status is 200": (r) => r.status === 200,
    "success present": (r) => r.body && r.body.includes('"success"'),
  });
}
