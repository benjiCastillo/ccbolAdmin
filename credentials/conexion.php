<?php
function Conectar () {
    $conn = null;
    $host = 'localhost';
    $db = 'ccbol_db';
    $user = 'root';
    $pwd = '';
    try{
        $conn = new PDO('mysql:host='.$host.';dbname='.$db, $user, $pwd, array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES \'UTF8\''));
        
        // echo '<p>El chuco!</p>';
        // var_dump($conn);
        
    }catch (PDOException $e) {
        echo '<p>No se puede conectar a la base de datos!</p>';
        exit;
    }
    return $conn;
}

// function Conectar () {
//     $link = mysqli_connect("localhost", "root", "", "ccbol_db");

//     if (!$link) {
//         echo "Error: Unable to connect to MySQL." . PHP_EOL;
//         echo "Debugging errno: " . mysqli_connect_errno() . PHP_EOL;
//         echo "Debugging error: " . mysqli_connect_error() . PHP_EOL;
//         exit;
//     }

//     // echo "Success: A proper connection to MySQL was made! The my_db database is great." . PHP_EOL;
//     // echo "Host information: " . mysqli_get_host_info($link) . PHP_EOL;

//     return $link;
// }

?>