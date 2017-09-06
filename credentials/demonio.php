<?php 
// Create the MySQL connection 
$mysqli = new mysqli('127.0.0.1', 'root', '', 'ccbol_db');

$pid = pcntl_fork(); 
             
if ( $pid == -1 ) {        
    // Fork failed            
    exit(1); 
} else if ( $pid ) { 
    // We are the parent 
    // Can no longer use $db because it will be closed by the child 
    // Instead, make a new MySQL connection for ourselves to work with 


    

} else { 
$mysqli = new mysqli('127.0.0.1', 'root', 'admin', 'ccbol_db');
    $sql = "SELECT * FROM user where id=744";

     for($i = 1; $i < 10;$i++) { 
     $date = date("h:i:s"); 

    if (!$result = $mysqli->query($sql)) {
        // Oh no! The query failed. 
        echo "Sorry, the website is experiencing problems.";

        // Again, do not do this on a public site, but we'll show you how
        // to get the error information
        echo "Error: Our query failed to execute and here is why: \n";
        echo "Query: " . $sql . "\n";
        echo "Errno: " . $mysqli->errno . "\n";
        echo "Error: " . $mysqli->error . "\n";
        exit;
}  
  $user = $result->fetch_assoc();

    echo "Nombre " . $user['name'] . " apellido " . $user['last_name'];
     sleep(1); 
 } 

    exit(0);
} 
?>