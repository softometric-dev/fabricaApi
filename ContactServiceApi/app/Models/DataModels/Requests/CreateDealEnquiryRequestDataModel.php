<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;
use App\Libraries\{ParameterException};

class CreateDealEnquiryRequestDataModel extends ApiRequestDataModel
{
    public $newDealEnquiry;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newDealEnquiry = $this->newDealEnquiry;
      	
        // Validate mandatory inputs
        if (
            is_null($newDealEnquiry) ||
            empty($newDealEnquiry->fullName) ||
            empty($newDealEnquiry->companyName)||
            empty($newDealEnquiry->email)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'fullName,companyName,email');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createDealEnquiryRequestDataModel = new CreateDealEnquiryRequestDataModel();
     
        if ($jsonData !== null) {
            $newDealEnquiry = isset($jsonData->newDealEnquiry) ? $jsonData->newDealEnquiry : null;	
            
            if($newDealEnquiry !== null )
				{
					$dealEnquiryDataModel = DealEnquiryDataModel::fromJson($newDealEnquiry);	
					$createDealEnquiryRequestDataModel->newDealEnquiry = $dealEnquiryDataModel;	
                    				
				}
        }

        return $createDealEnquiryRequestDataModel;
    }

}