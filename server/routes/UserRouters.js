import express from "express";

const router = express.Router();

router.post("/resgister", (req, res) => {
    res.status(200).json("resgister");
})

router.post("/login", (req, res) => {
    res.status(200).json("login");
})

router.post("/changePassword", (req, res) => {
    res.status(200).json("changePassword");
})

router.post("/logout", (req, res) => {
    res.status(200).json("logout");
})

router.post("/profile", (req, res) => {
    res.status(200).json("profile");
})

router.post("/forgot-password", (req, res) => {
    res.status(200).json("forgot-password");
})

export default router