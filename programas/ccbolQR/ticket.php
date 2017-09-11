<?php

if(empty($_GET['c']))
{
    require '404.php';
}
else{    
    /**
    * Creates an example PDF TEST document using TCPDF
    * @package com.tecnick.tcpdf
    * @abstract TCPDF - Example: Full page background
    * @author Nicola Asuni
    * @since 2009-04-16
    */

    // Include the main TCPDF library (search for installation path).
    require_once('TCPDF/tcpdf.php');

    // get ID of ticket
    $cont = $_GET['c'];
    $name = $_GET['n'];
    $apellido = $_GET['l'];

    // Extend the TCPDF class to create custom Header and Footer
    class MYPDF extends TCPDF {
        //Page header
        public function Header() {
            // get the current page break margin
            $bMargin = $this->getBreakMargin();
            // get current auto-page-break mode
            $auto_page_break = $this->AutoPageBreak;
            // disable auto-page-break
            $this->SetAutoPageBreak(true, 0);
            // set bacground image
            // $img_file = K_PATH_IMAGES.'back-pdf.jpg';
            // $this->Image($img_file, 0, 0, 220, 130, '', '', 'T', false, 300, '', false, false, 0, false, false, false);
 
            // restore auto-page-break status
            $this->SetAutoPageBreak($auto_page_break, $bMargin);
            // set the starting point for the page content
            $this->setPageMark();
        }
    }

    // create new PDF document
    $pdf = new MYPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, 'LETTER', true, 'UTF-8', false);

    // set document information
    $pdf->SetCreator(PDF_CREATOR);
    $pdf->SetAuthor('Ingeniería de Sistemas');
    $pdf->SetTitle('Ticket CCBOL 17');
    $pdf->SetSubject('Preinscripcion para la ccbol2017');
    $pdf->SetKeywords('USFX, PREINSCRIPCION, CCBOL2017, SUCRE, BOLIVIA');

    // set header and footer fonts
    $pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));

    // set default monospaced font
    $pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

    // set margins
    $pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
    $pdf->SetHeaderMargin(0);
    $pdf->SetFooterMargin(0);

    // remove default footer
    $pdf->setPrintFooter(false);

    // set auto page breaks
    $pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

    // set image scale factor
    $pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

    // set some language-dependent strings (optional)
    if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
        require_once(dirname(__FILE__).'/lang/eng.php');
        $pdf->setLanguageArray($l);
    }
    // add a page
    $pdf->AddPage();

    $pdf->Image(K_PATH_IMAGES.'logo-ccbol-2017.png', 70, 30,66.1,28.5, 'PNG', '', '', true, 150, '', false, false, 0, false, false, false);
    // Set some content to print
    $html = "
    <div>
        <h2>Felicidades,<small> ".$name." ".$apellido." Ya estas registrado para la CCBOL Sucre 2017.</small></h2>
    </div>";

    // Print text using writeHTMLCell()
    // $pdf->writeHTMLCell(0, 0, '', '', $html, 0, 1, 0, true, '', true);
    $pdf->writeHTMLCell($w=150, $h=0, $x='25', $y='52', $html, $border=0, $ln=1, $fill=0, $reseth=true, $align='C', $autopadding=true);


    $style = array(
        'position' => '',
        'align' => 'C',
        'stretch' => false,
        'fitwidth' => true,
        'cellfitalign' => '',
        'border' => true,
        'hpadding' => 'auto',
        'vpadding' => 'auto',
        'fgcolor' => array(0,0,0),
        'bgcolor' => false, //array(255,255,255),
        'text' => false,
        'font' => 'helvetica',
        'fontsize' => 8,
        'stretchtext' => 4
    );
    // CODE 128 AUTO
    $pdf->write1DBarcode($cont, 'C128', 65, 80, '', 18, 0.4, $style, 'N');
    $pdf->Ln();

    //Close and output PDF document
    // $pdf->IncludeJS('print();');
    $pdf->Output('ticket.pdf', 'I'); // D = Download I=Image

    //============================================================+
    // END OF FILE
    //============================================================+
}
?>