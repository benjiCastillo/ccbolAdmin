<?php

function encriptarID($id){
    return ($id+123).'a'.($id*135).'z'.($id+567);
}

function desencriptarID($id_enc){
    $g = explode('a',$id_enc);
    $v1 = $g[0];
    $v2 = explode('z',$g[1])[1];
    return ( ($v1-123)+($v2-567) )/2;
}

/*
echo '{';
for ($i=1;$i<=100;$i++){
    if($i==100){
        echo '"'.$i.'":"'.encriptar($i).'"'; 
    }
    else{
        echo '"'.$i.'":"'.encriptar($i).'",'; 
    }
}
echo '}';
*/

 /**** test ***/
 /*
$elem = array();
for ($i=1;$i<=3000;$i++){
    echo 'valor: '.$i.' --------- ';
    $x = encriptar($i);
    array_push($elem,$x);
    echo $x.'<br>';
}

foreach ($elem as $e) {
    //print_r($e);
    //echo '<br>';
    echo desencriptar($e).'<br>';
}
*/

//echo desencriptar('124a135z568');


?>