<?php 

namespace App\Model;


use App\Lib\Response,
	App\Lib\Security;

/**
* Modelo usuario
*/
class  UserModel
{
	private $db;
	private $table = 'user';
	private $response;



	public function __CONSTRUCT($mysqli){
		$this->mysqli   = $mysqli;
		$this->response = new Response();
		$this->security = new Security();
	}


	//registrar
	public function insert($data){
		// $data['password'] = md5($data['password']);

		$this->mysqli->insertInto($this->table, $data)
				 ->execute();

		return $this->response->setResponse(true);
		}

	/* INSERTAR Usuario */
	public function insertStudent($data){
			$recaptchadata =$data['grecaptcharesponse'];	
			if(isset($recaptchadata)){
				$secret = '6Ld_eCwUAAAAADTfNzABC8-JsuEYUwGO_4flVZOY';
				$recaptcha = new \ReCaptcha\ReCaptcha($secret);
				 $resp = $recaptcha->verify($recaptchadata, 'localhost');
				  if ($resp->isSuccess()){
						$this->mysqli->multi_query("CALL insertStudent('".$data['_name']."',
																'".$data['_last_name']."',
																'".$data['_ci']."',
																'".$data['_email']."',
																'".$data['_city']."',	
																'".$data['_college']."',
																'".$data['_career']."')");
						$res = $this->mysqli->store_result();
						$res = $res->fetch_array();
						mysqli_close($this->mysqli);
						if($res[1]=="yes")
							$res = array("message"=>$res[0], "error"=>$res[1], "response"=>true);
						else
							$res = array("message"=>$res[0], "id"=>$this->security->encriptar($res[2]), "error"=>$res[1], "response"=>true);
						return $res;	
					}else{

					  $res = array("message"=>'eres un robot',"error"=>'yes',"response"=>true);
					  return $res;
				  }

			}
	
	}

	public function insertProfessional($data){
			// importante https://www.phpbb.com/community/viewtopic.php?f=556&t=2404186
			$recaptchadata =$data['grecaptcharesponse'];	
			if(isset($recaptchadata)){
				$secret = '6Ld_eCwUAAAAADTfNzABC8-JsuEYUwGO_4flVZOY';
				$recaptcha = new \ReCaptcha\ReCaptcha($secret);
				 $resp = $recaptcha->verify($recaptchadata, 'localhost');
				  if ($resp->isSuccess()){
						$this->mysqli->multi_query("CALL insertProfessional('".$data['_name']."',
																'".$data['_last_name']."',
																'".$data['_ci']."',
																'".$data['_email']."',
																'".$data['_city']."',
																'".$data['_professional_degree']."')");
						$res = $this->mysqli->store_result();
						$res = $res->fetch_array();
						mysqli_close($this->mysqli);
						if($res[1]=="yes")
							$res = array("message"=>$res[0], "error"=>$res[1], "response"=>true);
						else
							$res = array("message"=>$res[0], "id"=>$this->security->encriptar($res[2]), "error"=>$res[1], "response"=>true);
						return $res;		
					}else{

					  $res = array("message"=>'eres un robot',"error"=>'yes',"response"=>true);
					  return $res;
				  }

			}

	}

	public function listStudents($data){
		$this->mysqli->multi_query("CALL listStudents()");
		$res = $this->mysqli->store_result();
		while($fila = $res->fetch_assoc()){
			$arreglo[] = $fila;
		}
		$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array("message"=>$res[0], "response"=>true);
		return $res;		
	}

	public function listProfessionals($data){
		$this->mysqli->multi_query("CALL listProfessionals()");
		$res = $this->mysqli->store_result();
		while($fila = $res->fetch_assoc()){
			$arreglo[] = $fila;
		}
		$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array("message"=>$res[0], "response"=>true);
		return $res;		
	}

	public function userPaidBc($data){
		$this->mysqli->multi_query(" CALL userPaidBc('".$data['_id_user']."',
                                                    '".$data['_id_admin']."')");

		$res = $this->mysqli->store_result();
			while ($fila = $res->fetch_assoc()) {
				$arreglo[] = $fila;
			}
		$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array($res[0], $res[1]);
		return $res;		 
}

	public function userPaidCi($data){
		$this->mysqli->multi_query(" CALL userPaidCi('".$data."')");

		$res = $this->mysqli->store_result();
			while ($fila = $res->fetch_assoc()) {
				$arreglo[] = $fila;
			}
		$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array("message"=>$res[0], "response"=>true);
		return $res;		 
	}

	public function listUserBc($data){
		$data = $this->security->desencriptarID($data);

		$this->mysqli->multi_query(" CALL listUserBc('".$data."')");

		$res = $this->mysqli->store_result();
		$res = $res->fetch_array();
		mysqli_close($this->mysqli);
		if($res[0] == 'yes'){
			$res = array("respuesta"=>$res[1],"error"=>"yes");
		}else{
			if($res[1] == 1){
				$res = array("error"=>$res[0],"type"=>$res[1],"_name"=>$res[2],"_last_name"=>$res[3],"_ci"=>$res[4],"_email"=>$res[5],"_city"=>$res[6],"_college"=>$res[9] ,"_career"=>$res[10],"_id"=>$res[11],"_cargo"=>$res[7] ,"response"=>true);
			}else{
				$res = array("error"=>$res[0],"type"=>$res[1],"_name"=>$res[2],"_last_name"=>$res[3],"_ci"=>$res[4],"_email"=>$res[5],"_city"=>$res[6],"_professional_degree"=>$res[9],"_id"=>$res[10] ,"_cargo"=>$res[7],"response"=>true);
			}
		}
		return $res;		 
}

	public function listUserCi($data){
		$this->mysqli->multi_query(" CALL listUserCi('".$data['_ci']."')");

		$res = $this->mysqli->store_result();
			while ($fila = $res->fetch_assoc()) {
				$arreglo[] = $fila;
			}
			$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array("message"=>$res[0], "response"=>true);
		return $arreglo;		 
	}

	public function adminLogin($data){
		$this->mysqli->multi_query(" CALL adminLogin('".$data['_count']."',
													'".$data['_password']."')");

		$res = $this->mysqli->store_result();
		$res = $res->fetch_assoc();
		mysqli_close($this->mysqli);
		return $res;			 
	}

	public function logout($data){
		$this->mysqli->multi_query(" CALL logout('".$data."')");

		$res = $this->mysqli->store_result();
			while ($fila = $res->fetch_assoc()) {
				$arreglo[] = $fila;
			}
			$res = $arreglo;
		mysqli_close($this->mysqli);
		$res = array("message"=>$res[0], "response"=>true);
		return $res;
	}
	
	public function updateUser($data){
		$this->mysqli->multi_query(" CALL updateUser('".$data['_id']."',
														'".$data['_id_admin']."',
														'".$data['_name']."',
														'".$data['_last_name']."',
														'".$data['_ci']."',
														'".$data['_email']."',
														'".$data['_city']."',
														'".$data['_cargo']."',
														'".$data['_career']."',
														'".$data['_college']."')");
			$res = $this->mysqli->store_result();
			$res = $res->fetch_assoc();
			mysqli_close($this->mysqli);
			return $res;					 
	}
	
	//actualizar
	public function update($data, $id){

		$this->db->update($this->table, $data, $id)	
				 ->execute();

		return $this->response->setResponse(true);		 
	}
	//eliminar
	public function delete($id){

		$this->db->deleteFrom($this->table, $id)	
				 ->execute();

		return $this->response->setResponse(true);		 
	}


}


 ?>
