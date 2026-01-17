import http from "k6/http";
import { sleep } from "k6";

const BASE_URL = "http://localhost:3001"; // ✅ change this

export const options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      rate: 5000, // ✅ 1000 req/sec
      timeUnit: "1s",
      duration: "60s", // run 10 seconds
      preAllocatedVUs: 500,
      maxVUs: 5000,
    },
  },
};

function randomPhone() {
  const first = Math.random() < 0.5 ? "8" : "9";
  const rest = Math.floor(Math.random() * 1000000000)
    .toString()
    .padStart(9, "0");
  return first + rest;
}

export default function () {
  const phone = randomPhone();

  const url = `${BASE_URL}/send-otp-channel`; // ✅ change endpoint

  const payload = JSON.stringify({
    mobile: phone, // ✅ change key if needed
  });

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  http.post(url, payload, params);
}
