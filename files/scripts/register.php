<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "aquadactyl";

// Создаем соединение
$conn = new mysqli($servername, $username, $password, $dbname);

// Проверяем соединение
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Получаем данные из формы
$user = $_POST['username'];
$lastname = $_POST['lastname'];
$email = $_POST['email'];
$pass = password_hash($_POST['password'], PASSWORD_DEFAULT);

// Вставляем данные в базу данных
$sql = "INSERT INTO users (username, lastname, email, password) VALUES ('$user', '$lastname', '$email', '$pass')";
if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
