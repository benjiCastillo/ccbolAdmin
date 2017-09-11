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
?>