<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};

class CreateBrandRequestDataModel extends ApiRequestDataModel
{
    public $newBrand;

    public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newBrand = $this->newBrand;
      	
        // Validate mandatory inputs
        if (
            is_null($newBrand) ||
            empty($newBrand->brandName) ||
            empty($newBrand->category->categoryId)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'brandName,categoryId');
        }
    }

    public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createBrandRequestDataModel = new CreateBrandRequestDataModel();
     
        if ($jsonData !== null) {
            $newBrand = isset($jsonData->newBrand) ? $jsonData->newBrand : null;	
            
            if($newBrand !== null )
				{
					$brandDataModel = BrandDataModel::fromJson($newBrand);	
					$createBrandRequestDataModel->newBrand = $brandDataModel;	
                    				
				}
        }

        return $createBrandRequestDataModel;
    }

}