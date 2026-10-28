import express from "express";

const app = express();

app.listen(5001, () => {
    console.log("Server đang lắng nghe cổng 5001");
})

