import express from "express";

const router = express.Router();

router.post("/add", (req, res) => {
    res.status(200).json("add");
})

router.post("/update", (req, res) => {
    res.status(200).json("update");
})

router.post("/delete", (req, res) => {
    res.status(200).json("delete");
})

export default router