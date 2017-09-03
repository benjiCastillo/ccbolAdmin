<?php 

namespace App\Model;

use App\Lib\Response,
	App\Lib\Security;

/**
* Modelo usuario
*/
class  LocationModel
{
	private $db;
	private $table = 'location';
	private $response;



	public function __CONSTRUCT($mysqli){
		$this->mysqli   = $mysqli;
		$this->response = new Response();
		$this->security = new Security();
	}

	//var $l => 'limit', $p => 'pagina'

	//lista_total
	public function listar(){

		return $data = $this->db->from($this->table)
						 ->orderBy('id DESC')
						 ->fetchAll();
	//  return $data = $this->mysqli->query('select * from '.$this->table)
	//					 			->fetchAll();				   						 
	}

	//listar paginado
	//parametros de limite, pagina
	public function paginated($l, $p){	
		$p = $p*$l;
		$data = $this->db->from($this->table)
						 ->limit($l)
						 ->offset($p)
						 ->orderBy('id desc')
						 ->fetchAll();

		$total = $this->db->from($this->table)
						  ->select('COUNT(*) Total')
						  ->fetch()
						  ->Total;

		return [
			'data'	=>   $data,
			'total' =>   $total

		];				  						 
	}
	//obtener
	public function getExamen($id){

		return $data = $this->db->from($this->table, $id)
								->fetch();  						 
	}
	//registrar
	public function insert($data){
		// $data['password'] = md5($data['password']);

		$this->mysqli->insertInto($this->table, $data)
				 ->execute();

		return $this->response->setResponse(true);
		}

	/* INSERTAR EXAMEN */
	public function insertTest($data){
		$this->mysqli->multi_query("CALL insertarExamen('".$data['_id_medico']."',
														'".$data['_id_paciente']."')");
			$res = $this->mysqli->store_result();
			$res = $res->fetch_array();
			mysqli_close($this->mysqli);
			$res = array("message"=>$res[0],"response"=>true);
			return $res;	
	}

	public function listLodgings(){
		$this->mysqli->multi_query(" CALL listLodgings()");
			$res = $this->mysqli->store_result();
			while($fila = $res->fetch_assoc()){
				$arreglo[] = $fila;
			}
			$res = $arreglo;
			mysqli_close($this->mysqli);
			if($res[0]["error"] == "yes"){
				$res = array("respuesta"=>$res[0]["respuesta"], "error"=>$res[0]["error"]);
			}else{
				$res = array("message"=>$res, "error"=>"not", "response"=>true);
			}
			return $res;
			// $res = array("message"=>$res, "response"=>true);
			// return $res;		
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