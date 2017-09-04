<?php
function Conectar () {
    $conn = null;
    $host = 'localhost';
    $db = 'ccbol';
    $user = 'root';
    $pwd = '';
    try{
        $conn = new PDO('mysql:host='.$host.';dbname='.$db, $user, $pwd, array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES  \'UTF8\''));
        
    }catch (PDOException $e) {
        echo '<p>No se puede conectar a la base de datos!</p>';
        exit;
    }
    return $conn;
}

?>