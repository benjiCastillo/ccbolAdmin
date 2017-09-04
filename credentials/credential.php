<?php
// $id=$_GET[132];
$id=132;
header('Content-Type: text/html; charset=ISO-8859-1');
require_once('tcpdf/tcpdf.php');
require('conexion.php');

$con=Conectar();

$sqlp = 'SELECT name, last_name, cargo FROM user WHERE id=?';
$stmtp = $con->prepare($sqlp);
$resultsp = $stmtp->execute(array($id));
$rowp = $stmtp->fetchAll();

$pageLayout = array('85', '55'); //  or array($height, $width) 
// $pdf = new TCPDF('p', 'pt', $pageLayout, true, 'UTF-8', false);

$pdf = new TCPDF('P', PDF_UNIT, $pageLayout, true, 'UTF-8', false);
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor('CCBOL USFX 2017');
$pdf->SetTitle('Credenciales CCBOL');
$pdf->SetSubject('CCBOL');
$pdf->SetKeywords('CCBOL, USFX, Credenciales');
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
$pdf->SetFont('helvetica', '', 12);
$pdf->SetLeftMargin(15);
$pdf->AddPage();

// $pdf->setTextShadow(array('enabled'=>true, 'depth_w'=>0.2, 'depth_h'=>0.2, 'color'=>array(196,196,196), 'opacity'=>1, 'blend_mode'=>'Normal'));
// $pdf->SetFillColor(59,78,20);
$pdf->SetTextColor(37,65,98);

// draw jpeg image

$pdf->SetFont('helvetica','',9);
$firm = '<div style="line-height: 12px;">
            <p>El chuco</p>
        </div>';
$pdf->writeHTMLCell($w=0, $h=0, $x='10', $y='10', $firm, $border=0, $ln=1, $fill=0, $reseth=true, $align='C', $autopadding=true);

// $pdf->IncludeJS("print();");
$pdf->Output('Prueba.pdf', 'I');
?>