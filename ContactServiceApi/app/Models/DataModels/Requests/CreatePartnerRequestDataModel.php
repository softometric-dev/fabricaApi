<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PartnerDataModel;
use App\Libraries\{ParameterException};

class CreatePartnerRequestDataModel extends ApiRequestDataModel
{
    public $newPartner;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newPartner = $this->newPartner;
      	
        // Validate mandatory inputs
        if (
            is_null($newPartner) ||
            empty($newPartner->fullName) ||
            empty($newPartner->companyName)||
            empty($newPartner->email)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'fullName,companyName,email');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createPartnerRequestDataModel = new CreatePartnerRequestDataModel();
     
        if ($jsonData !== null) {
            $newPartner = isset($jsonData->newPartner) ? $jsonData->newPartner : null;	
            
            if($newPartner !== null )
				{
					$partnerDataModel = PartnerDataModel::fromJson($newPartner);	
					$createPartnerRequestDataModel->newPartner = $partnerDataModel;	
                    				
				}
        }

        return $createPartnerRequestDataModel;
    }

}