<?php
    //============================================================+
    // File name   : example_051.php
    // Begin       : 2009-04-16
    // Last Update : 2013-05-14
    //
    // Description : Example 051 for TCPDF class
    //               Full page background
    //
    // Author: Nicola Asuni
    //
    // (c) Copyright:
    //               Nicola Asuni
    //               Tecnick.com LTD
    //               www.tecnick.com
    //               info@tecnick.com
    //============================================================+

    /**
    * Creates an example PDF TEST document using TCPDF
    * @package com.tecnick.tcpdf
    * @abstract TCPDF - Example: Full page background
    * @author Nicola Asuni
    * @since 2009-04-16
    */

    // Include the main TCPDF library (search for installation path).
    require_once('TCPDF/tcpdf.php');

    // create new PDF document
    $pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

    // set document information
    $pdf->SetCreator(PDF_CREATOR);
    $pdf->SetAuthor('Ingeniería de Sistemas');
    $pdf->SetTitle('Credencial CCBOL 17');
    $pdf->SetSubject('Credencial Oficial ccbol2017');
    $pdf->SetKeywords('USFX, CREDENCIAL, CCBOL2017, SUCRE, BOLIVIA');

    // remove default header/footer
    $pdf->setPrintHeader(false);
    $pdf->setPrintFooter(false);

    // set default monospaced font
    $pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

    // set margins
    $pdf->SetMargins(10, PDF_MARGIN_TOP, 10);

    // set auto page breaks
    $pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

    // set image scale factor
    $pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

    // set some language-dependent strings (optional)
    if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
        require_once(dirname(__FILE__).'/lang/eng.php');
        $pdf->setLanguageArray($l);
    }

    // ---------------------------------------------------------

    $pdf->SetDisplayMode('fullpage', 'SinglePage', 'UseNone');
    
    // set page format (read source code documentation for further information)
    // MediaBox - width = urx - llx 210 (mm), height = ury - lly = 297 (mm) this is A4
    $page_format = array(
        'MediaBox' => array ('llx' => 0, 'lly' => 0, 'urx' => 215.9, 'ury' => 279.4),
        'Dur' => 3,
        'trans' => array(
            'D' => 1.5,
            'S' => 'Split',
            'Dm' => 'V',
            'M' => 'O'
        ),
        'Rotate' => 0,
        'PZ' => 1,
    );

    // Check the example n. 29 for viewer preferences

    // add first page ---
    $pdf->AddPage('P', $page_format, false, false);

    $pdf->Image(K_PATH_IMAGES.'logo-ccbol-2017.png', 70, 10,52.88,22.8, 'PNG', '', '', true, 150, '', false, false, 0, false, false, false);
    // Set some content to print

    // MultiCell($w, $h, $txt, $border=0, $align='J', $fill=0, $ln=1, $x='', $y='', $reseth=true, $stretch=0, $ishtml=false, $autopadding=true, $maxh=0)

    /* Variabkles Dinamicas */
    $cajero = $_GET['caja'];
    $nro = '000'.$_GET['userid'];
    $price = $_GET['price'];
    $ci = $_GET['ci'];
    $priceText = 'Trescientos Bolivianos';
    $concepto = 'Congreso Nacional Ccbol - 2017';

    $name = $_GET['name'];
    $day = date('d');
    $month = date('m');
    $year = date('Y');
    $city = 'Sucre';

    /*Variable Default
    $cajero = 'cajero-1';
    $nro = '000'+$userID;
    $price = '300';
    $priceText = 'Trescientos Bolivianos';
    $concepto = 'Congreso Nacional Ccbol - 2017';

    $name = 'Jose Alex Chirinos Balderrama';
    $day = date('d');
    $month = date('m');
    $year = date('Y');
    $city = 'Sucre';
    */

    /* config visual */
    $bc = 0;

    //config general
    $pdf->setCellPaddings(1, 1, 1, 1);
    /*$pdf->SetFont('SF Pro Display', '', 10);*/

    $pdf->Ln(10);
    // set some text for example
    $txt = 'Recibo de Inscripción';

    $pdf->SetFillColor(255, 255, 255);
    $pdf->SetFont ('helvetica', 'B', 16 , '', 'default', true );
    $pdf->MultiCell(100, 8, $txt, $bc, 'C', 1, 0, 58, '', true);

    $pdf->setCellMargins(1,10, 1, 1);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(15, 8, 'Nro.', $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(25, 8, $nro, $bc, 'L', 1, 0, 55, '', true);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(10, 8, 'Bs. ', $bc, 'L', 1, 0, 100, '', true);    
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(30, 8, $price, $bc, 'L', 1, 0, 110, '', true);    

    $pdf->setCellMargins(1,20, 1, 1);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(20, 8, 'Nombre:', $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(80, 8, $name, $bc, 'L', 1, 0, 60, '', true);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(10, 8, 'CI:', $bc, 'L', 1, 0, 140, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(30, 8, $ci, $bc, 'L', 1, 0, 150, '', true);

    $pdf->setCellMargins(1,30, 1, 1);
    $pdf->SetFont ('helvetica', 'B', 12 , '', 'default', true );
    $pdf->MultiCell(20, 8, 'Ciudad: ', $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(15, 8, $city, $bc, 'L', 1, 0, 60, '', true);
    $pdf->MultiCell(35, 8, 'Dia: '.$day, $bc, 'C', 1, 0, 75, '', true);
    $pdf->MultiCell(35, 8, 'Mes: '.$month, $bc, 'C', 1, 0, 110, '', true);
    $pdf->MultiCell(35, 8, 'Año: '.$year, $bc, 'L', 1, 0, 145, '', true);

    $pdf->setCellMargins(1,40, 1, 1);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(25, 8, 'Recibí de: ', $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(115, 8, $name, $bc, 'L', 1, 0, 65, '', true);

    $pdf->setCellMargins(1,50, 1, 1);
    $pdf->SetFont ('helvetica', 'BI', 12 , '', 'default', true );
    $pdf->MultiCell(40, 8, 'La suma de: ', $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', '', 12 , '', 'default', true );
    $pdf->MultiCell(100, 8, $priceText, $bc, 'L', 1, 0, 80, '', true);

    $pdf->setCellMargins(1,60, 1, 1);
    $pdf->SetFont ('helvetica', 'I', 12 , '', 'default', true );
    $pdf->MultiCell(140, 8, 'Por concepto de: '.$concepto, $bc, 'L', 1, 0, 40, '', true);

    $pdf->setCellMargins(1,70, 1, 1);
    $pdf->SetFont ('helvetica', 'B', 16 , '', 'default', true );
    $pdf->MultiCell(70, 10, 'Total: '.$price, $bc, 'L', 1, 0, 40, '', true);
    $pdf->SetFont ('helvetica', 'I', 12 , '', 'default', true );
    $pdf->MultiCell(70, 10, 'Emitido por: '.$cajero, $bc, 'L', 1, 0, 110, '', true);

    //Close and output PDF document
    $pdf->Output('example_028.pdf', 'I');

    //============================================================+
    // END OF FILE
    //============================================================+
?>