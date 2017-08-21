<?php 
namespace App\Validation;

use App\Lib\Response;

/**
* Validacion para el paciente
*/
class UserValidation {
	
	public static function validate($data){

		$response = new Response();

		$key = 'nombre';

		if(empty($data[$key])){
			$response->errors[$key][] = 'Este Campo es Obligatorio';
		}else{
			$value = $data[$key];
			if(strlen($value) < 4){
				$response->errors[$key][] = 'Debe contener como minimo 2 caracteres';
			}

		}


		$key = 'correo';

		if(empty($data[$key])){
			$response->errors[$key][] = 'Este Campo es Obligatorio';
		}else{

			$value = $data[$key];
			if ( !filter_var($value, FILTER_VALIDATE_EMAIL)) {
			   $response->errors[$key][] = 'Correo no valido';
			}

		}

		$key = 'password';

		if(empty($data[$key])){
			$response->errors[$key][] = 'Este Campo es Obligatorio';
		}else{
	
			$value = $data[$key];
			if(strlen($value) < 4){
				$response->errors[$key][] = 'Debe tener como minimo 4 caracteres';
			}

		}

		$response->setResponse(count($response->errors) === 0);
		return $response;
	}


	
}


 ?>