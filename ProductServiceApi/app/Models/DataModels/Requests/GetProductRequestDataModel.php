<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Libraries\{ParameterException};


class GetProductRequestDataModel extends ApiRequestDataModel
{

    public $product;
  
	 public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $product = $this->product;

        // Validate mandatory inputs
        if (empty($product) || empty($product->productId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'productId');
        }
    }

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$getProductRequestDataModel = new GetProductRequestDataModel();
		if ($jsonData != null) {

            $product = isset($jsonData->product) ? $jsonData->product : null;
			if ($product != null) {
				$productDataModel = ProductDataModel::fromJson($product);
				$getProductRequestDataModel->product = $productDataModel;
			}


		}
		return $getProductRequestDataModel;
	}


}