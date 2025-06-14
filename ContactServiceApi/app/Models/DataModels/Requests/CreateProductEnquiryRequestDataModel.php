<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;
use App\Libraries\{ParameterException};

class CreateProductEnquiryRequestDataModel extends ApiRequestDataModel
{
    public $newProductEnquiry;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newProductEnquiry = $this->newProductEnquiry;
      	
        // Validate mandatory inputs
        if (
            is_null($newProductEnquiry) ||
            empty($newProductEnquiry->fullName) ||
            empty($newProductEnquiry->companyName)||
            empty($newProductEnquiry->email)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'fullName,companyName,email');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createProductEnquiryRequestDataModel = new CreateProductEnquiryRequestDataModel();
     
        if ($jsonData !== null) {
            $newProductEnquiry = isset($jsonData->newProductEnquiry) ? $jsonData->newProductEnquiry : null;	
            
            if($newProductEnquiry !== null )
				{
					$productEnquiryDataModel = ProductEnquiryDataModel::fromJson($newProductEnquiry);	
					$createProductEnquiryRequestDataModel->newProductEnquiry = $productEnquiryDataModel;	
                    				
				}
        }

        return $createProductEnquiryRequestDataModel;
    }

}