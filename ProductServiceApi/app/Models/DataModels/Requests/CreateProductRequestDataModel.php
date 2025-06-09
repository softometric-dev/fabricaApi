<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Libraries\{ParameterException};
class CreateProductRequestDataModel extends ApiResponseDataModel
{
    public $newProduct;

     public function __construct()
    {
        parent::__construct();
    }
    
    public function validateAndEnrichData()
    {
       
        $newProduct = $this->newProduct;
      	
        // Validate mandatory inputs
        if (
            is_null($newProduct) ||
            empty($newProduct->productName) || empty($newProduct->size) || empty($newProduct->category->categoryId)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'productName,size,categoryId');
        }
    }


     public static function fromJson($jsonString)
	{
        
       
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
		$createProductRequestDataModel = new CreateProductRequestDataModel();
     
        if ($jsonData !== null) {
            $newProduct = isset($jsonData->newProduct) ? $jsonData->newProduct : null;	
            
            if($newProduct !== null )
				{
					$productDataModel = ProductDataModel::fromJson($newProduct);	
					$createProductRequestDataModel->newProduct = $productDataModel;	
                    				
				}
        }

        return $createProductRequestDataModel;
    }

}