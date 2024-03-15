<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'src/Exception.php';
require 'src/PHPMailer.php';
require 'src/SMTP.php';

$captcha;

if($_POST) {
    $name=$_POST['name'];
    $subject=$_POST['subject'];
    $email=$_POST['email'];
    $message=$_POST['message'];
    $mail = new PHPMailer;
}
    else 
    {
   echo "N0, mail is not set";
    }

if(isset($_POST['g-recaptcha-response'])){
$captcha=$_POST['g-recaptcha-response'];
}

    if(!$captcha){
        echo '<h2>Please check the the captcha form.</h2>';
        exit;
      }
      $secretKey = "6LcWEdsZAAAAAM7TmU7S5zxsGVN06RFwW0pEFgv1";
      //$ip = $_SERVER['192.168.0.7'];
      // post request to server
      $url = 'https://www.google.com/recaptcha/api/siteverify?secret=' . urlencode($secretKey) .  '&response=' . urlencode($captcha);
      $response = file_get_contents($url);
      $responseKeys = json_decode($response,true);
      // should return JSON with success as true


        if (($name=="")||($email=="")||($message=="")){
		echo'<script type="text/javascript">
                alert("llene los datos requeridos *");
                window.location.href="contacto.html";
                </script>';
        }

        if($responseKeys["success"]) {
                echo '<h2>You are spammer ! Get the @$%K out</h2>';
        
        } else {

                try {
                        $mail->isSMTP();                                      // Usar SMTP
                        $mail->Host = 'smtp.zoho.com';  // Especificar el servidor SMTP reemplazando por el nombre del servidor donde esta alojada su cuenta
                        $mail->SMTPAuth = true;                               // Habilitar autenticacion SMTP
                        $mail->Username = 'soporte@audisoft.com';                 // Nombre de usuario SMTP donde debe ir la cuenta de correo a utilizar para el envio
                        $mail->Password = '8rSYHVBGLQIoymHQb9um';                           // Clave SMTP donde debe ir la clave de la cuenta de correo a utilizar para el envio
                        $mail->SMTPSecure = 'ssl';                            // Habilitar encriptacion
                        $mail->Port = 465;                                    // Puerto SMTP                     
                        //$mail->Timeout       =   30;
                        //$mail->AuthType = 'LOGIN';
                    
                        //Destinatarios 
                        
                        $mail->setFrom('soporte@audisoft.com');     //Direccion de correo remitente (DEBE SER EL MISMO "Username")
                        $mail->addAddress('jmolina@audisoft.com');     // Agregar el destinatario
                        //$mail->addBCC($email); // Direccion con copia del envío
                        //$mail->addReplyTo('correo@sudominio.com');     //Direccion de correo para respuestas     
                    
                
                    
                        //Contenido
                        $mail->isHTML(true);
                        //$mail->"Content-Type: text/html; charset=UTF-8";
                        $mail->CharSet = 'UTF-8'; 
                        $mail->Subject = 'Mensaje de la página web';
                        $mail->Body    = "Nombre: $name <br> Teléfono: $subject <br> Correo: $email <br>  Mensaje: $message <br>"; // Contenido del mensaje. 
                        
                        $mail->send();
                        //alert("El mensaje ha sido enviado correctamente"); 
                        //echo 'El mensaje ha sido enviado';
                        echo'<script type="text/javascript">
                                alert("Mensaje enviado correctamente");
                            window.location.href="contacto.html";
                            </script>';
                    } catch (Exceptio $e){
                        echo 'El mensaje no pudo ser enviado. Mailer Error: ', $mail->ErrorInfo;
                    }
                
        }
?>