<?php

namespace App\Models\Common;

use CodeIgniter\Model;
use App\Libraries\DatabaseException as Cust_DatabaseException;
use CodeIgniter\Database\Exceptions\DatabaseException;

class Base_model extends Model
{
    // Properties
    protected $DBGroup = 'default'; // Adjust if you're using multiple database groups
    protected $table;
    protected $primaryKey;
    protected $returnType = 'array'; // or 'object'
    protected $useSoftDeletes = false;
    
    protected $baseUrl; // Adding the $baseUrl property

    // Constructor
    public function __construct()
    {
       
        parent::__construct();
        $this->db = \Config\Database::connect($this->DBGroup);
       
        // Initialize $baseUrl property if needed
        $this->baseUrl = base_url(); // or set it to a specific value
    }

    protected function checkDBError()
    {
       
        $error = $this->db->error();

        if ($error['code'] != 0) 
        {
            $errorCode = $error['code'];
            $errorMessage = $error['message'];

            if ($errorCode == 1062) 
            {
                throw new Cust_DatabaseException(DB_DUPLICATE_RECORD, 'DB Error code - ' . $errorCode . ' : ' . $errorMessage);
            } 
            else 
            {
                throw new Cust_DatabaseException(DB_ERROR, $errorCode . ' : ' . $errorMessage);
            }
        }
    }
}
