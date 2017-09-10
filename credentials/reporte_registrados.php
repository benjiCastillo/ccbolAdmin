<?php

require_once('tcpdf/tcpdf.php');
require('conexion.php');

header('Content-Type: text/html; charset=ISO-8859-1');

$con=Conectar();

$sql = 'SELECT name, last_name, ci, email, city, registration_date, inscription_date, FROM user WHERE id=132';
$stmt = $con->prepare($sql);
$results = $stmt->execute();
// $row = $stmt->fetchAll();
$row = $stmt->fetchAll();

// $gsent = $gbd->prepare("SELECT name, colour FROM fruit");
// $gsent->execute();

// /* Obtener todas las filas restantes del conjunto de resultados */
// print("Obtener todas las filas restantes del conjunto de resultados:\n");
// $resultado = $stmt->fetchAll();
// print_r($resultado);


// $custom_layout = array('215.9', '107.9');
$pdf = new TCPDF('P', PDF_UNIT, 'LETTER', true, 'UTF-8', false);
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('CCBOL 2017 ADMINISTRADOR');
$pdf->SetTitle('REPORTE DE ACREDITACIÓN CCBOL 2017');
$pdf->SetSubject('CCBOL 2017');
$pdf->SetKeywords('CCBOL 2017, REPORTE, ACREDITADOS');
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(false);
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);
$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetAutoPageBreak(TRUE, '0');
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

if (@file_exists(dirname(__FILE__).'/tcpdf/example/lang/spa.php')) {
    require_once(dirname(__FILE__).'/tcpdf/example/lang/spa.php');
    $pdf->setLanguageArray($l);
}
$pdf->SetLeftMargin(15);
$pdf->AddPage();

$pdf->SetTextColor(37,65,98);

// $pdf->Cell(0, 15, '                         LABORATORIO DE ANÁLISIS CLÍNICO "VOS ANDES"', 0, false, 'L', 0, '', 0, false, 'M', 'M');
$titleP = '<p><b>REPORTE ACREDITACIÓN CCBOL 2017</b></p>';
$pdf->writeHTML($titleP, true, false, false, false, 'C');

// set alpha to semi-transparency
$pdf->SetAlpha(0.1);
$pdf->Image(K_PATH_IMAGES.'logo-ccbol-2017.png', 25, 50,175,170, 'PNG', '', '', true, 100, '', false, false, 0, false, false, false);
$pdf->SetAlpha(1);
// draw jpeg image
// $pdf->Image(K_PATH_IMAGES.'fondo.jpg', 48, 25, 120, 80, '', '', '', true, 200);

$pdf->Ln(8);
// foreach ($row as $rows){
// $initData = '<table>
//         <tr>
//             <td>Nombres</td>
//             <td>Apellidos</td>
//             <td>Carnet de Identidad</td>
//             <td>Ciudad</td>
//             <td>Fecha de Pre-inscripción</td>
//             <td>Fecha de Acreditación</td>
//         </tr>

//     </table>
// ';
// }

foreach ($row as $rows) {
    $initData .= '<table>
             <tr>
                 <td>Nombres</td>
                 <td>Apellidos</td>
                 <td>Carnet de Identidad</td>
                 <td>Ciudad</td>
                 <td>Fecha de Pre-inscripción</td>
                 <td>Fecha de Acreditación</td>
             </tr>
            <tr>
                <td>'.$rows[0].'</td>
                <td>'.$rows[1].'</td>
                <td>'.$rows[2].'</td>
                <td>'.$rows[3].'</td>
                <td>'.$rows[4].'</td>
                <td>'.$rows[5].'</td>
            </tr>
         </table>';
}


$pdf->writeHTMLCell($w=180, $h=0, $x='40', $y='', $initData, $border=0, $ln=1, $fill=0, $reseth=true, $align='L', $autopadding=true);

// $pdf->Output('Reporte_Acreditados.pdf', 'I');
?>