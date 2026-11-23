import axios from "axios";

const configuredApiUrl = import.meta.env.VITE_API_URL?.trim();

const getApiBaseUrl = () => {
    if (configuredApiUrl) {
        return configuredApiUrl.replace(/\/$/, "");
    }

    if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
        return "http://localhost:8081";
    }

    if (window.location.hostname.includes("-frontend-production")) {
        return `https://${window.location.hostname.replace(
            "-frontend-production",
            "-backend-production"
        )}`;
    }

    return window.location.origin;
};

const API = axios.create({
    baseURL: getApiBaseUrl(),
});

API.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if (token) {
        config.headers["Authorization"] = `Bearer ${token}`;
    }
    return config;
});

API.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401 || error.response?.status === 403) {
            localStorage.removeItem("token");
            localStorage.removeItem("role");
            localStorage.removeItem("stationName");
            localStorage.removeItem("username");
            localStorage.removeItem("fullName");
            localStorage.removeItem("trainNumber");
        }
        return Promise.reject(error);
    }
);

export default API;
