<?php 
require("print.php");

  // Simple demonio escrito en PHP 
   
  // Primero creamos un proceso hijo 
  $pid = pcntl_fork(); 
  if($pid == -1){ 
      die("Algo pasó con el forking del proceso!"); 
  } 
   
 // Preguntamos si somos el proceso padre o el hijo recien construido 
 if($pid) { 
     // Soy el padre por lo tanto necesito morir 
     exit("Proceso padre terminado...n"); 
 } 
  
 // De aqui en adelante solo se ejecuta si soy el hijo y futuro daemon 
  
 // Lo siguiente que hacemos es soltarnos de la terminal de control 
 if (!posix_setsid()) { 
     die ("No pude soltarme de la terminal"); 
 } 
  
 // De este punto en adelante debemos cambiarnos de directorio y 
 // hacemos las recomendaciones de Wikipedia para un daemon 
 chdir("/"); 
 umask(0); 
  
 // Si estamos aqui oficialmente somos un daemon 
 for($i = 1; $i < 10;$i++) { 
    //  $date = date("h:i:s"); 
    //  echo "$date hola amigo, te saluda el daemon!n"; 
     credenciales(1,2);
     sleep(1); 
 } 
  
 // Aki termino la demo, hora de morir 
 exit("Daemon terminado...n"); 
 ?>