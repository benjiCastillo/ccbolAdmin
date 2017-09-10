<?php
// $id_admin1 = $_GET['id_admin'];
// $id_admin2 = $_GET['id_admin'];

// while(true){
    $id_admin1 = 1;
    $id_admin2 = 2;
    require('conexion.php');
    header('Content-Type: text/html; charset=ISO-8859-1');
    require_once('tcpdf/tcpdf.php');

    $row_aux = null;
    while(true){
        credenciales($id_admin1, $id_admin2);
        sleep(1);
        
    }
    function credenciales($admin1, $admin2){

        $con=Conectar();
        
        $sql = "SELECT count(id) as cantidad FROM user WHERE (id_admin=$admin1 OR id_admin=$admin2) AND (paid=1) AND (printed=0) AND (printed_check=0) ORDER BY inscription_date ASC";
        if (!$result = $con->query($sql)) {
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
        if ($result->num_rows === 0) {
            // Oh, no rows! Sometimes that's expected and okay, sometimes
            // it is not. You decide. In this case, maybe actor_id was too
            // large? 
            echo "We could not find a match, sorry about that. Please try again.";
            exit;
        }
        
        // Now, we know only one result will exist in this example so let's 
        // fetch it into an associated array where the array's keys are the 
        // table's column names
        $row = $result->fetch_assoc();
        // $sql1 = "SELECT name, last_name, cargo FROM user WHERE (id_admin=$admin1 OR id_admin=$admin2) AND (paid=1) AND (printed=0) AND (printed_check=0) ORDER BY inscription_date ASC";
        // if (!$result1 = $con->query($sql1)) {
        //     // Oh no! The query failed. 
        //     echo "Sorry, the website is experiencing problems.";
        
        //     // Again, do not do this on a public site, but we'll show you how
        //     // to get the error information
        //     echo "Error: Our query failed to execute and here is why: \n";
        //     echo "Query: " . $sql . "\n";
        //     echo "Errno: " . $mysqli->errno . "\n";
        //     echo "Error: " . $mysqli->error . "\n";
        //     exit;
        // }
        // if ($result1->num_rows === 0) {
        //     // Oh, no rows! Sometimes that's expected and okay, sometimes
        //     // it is not. You decide. In this case, maybe actor_id was too
        //     // large? 
        //     echo "We could not find a match, sorry about that. Please try again.";
        //     exit;
        // }
        
        // // Now, we know only one result will exist in this example so let's 
        // // fetch it into an associated array where the array's keys are the 
        // // table's column names
        // $row1 = $result1->fetch_assoc();

        // echo 'registrados = '.$row['cantidad'].'';

        // $sql = 'SELECT count(id) FROM user WHERE (id_admin=? OR id_admin=?) AND (paid=1) AND (printed=0) AND (printed_check=0) ORDER BY inscription_date ASC';
        // $stmt = $con->prepare($sql);
        // $results = $stmt->execute(array($admin1, $admin2));
        // $row = $stmt->fetchAll();
        
        //     // echo 'pagados = '.$row['cantidad'].' usuarios';

            while($row['cantidad']<=10){

                    $pdf = new TCPDF('P', PDF_UNIT, 'letter', true, 'UTF-8', false);
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
                    $cont = 1;
                    $content = '<div><p>'.$row['cantidad'].' '.$cont.'</div>';
                    $cont++;
                    $pdf->writeHTMLCell($w=0, $h=0, $x='5', $y='1', $content, $border=0, $ln=1, $fill=0, $reseth=true, $align='L', $autopadding=true);
                    if($row['cantidad']==10){
                        $pdf->IncludeJS("this.print();");
                        
                    }
                    $pdf->Output('Prueba.pdf', 'I');      
            }
            echo '<h1>Error<h1>';
    
    }
    // credenciales($id_admin1, $id_admin2);
// }
    
?>