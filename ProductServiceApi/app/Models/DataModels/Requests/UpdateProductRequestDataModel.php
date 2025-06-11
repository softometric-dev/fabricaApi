<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};


class UpdateProductRequestDataModel extends ApiRequestDataModel
{

    public $product;
    public $brand;
    public $category;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $product = $this->product;

        // Validate mandatory inputs
        if (empty($product) || empty($product->productId) || empty($product->productModifiedDateTime)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'productId, p_productModifiedDateTime');
        }

        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$updateProductRequestDataModel = new UpdateProductRequestDataModel();
		if ($jsonData != null) {


            $product = $jsonData->product ?? null;
			if ($product != null) {
				$productDataModel = ProductDataModel::fromJson($product);
				$updateProductRequestDataModel->product = $productDataModel;
			}

            $brand = isset($jsonData->brand) ? $jsonData->brand : null;
			if ($brand != null) {
				$brandDataModel = BrandDataModel::fromJson($brand);
				$updateProductRequestDataModel->brand = $brandDataModel;
			}

             $category = isset($jsonData->category) ? $jsonData->category : null;
			if ($category != null) {
				$categoryDataModel = CategoryDataModel::fromJson($category);
				$updateProductRequestDataModel->category = $categoryDataModel;
			}
     
		}
		return $updateProductRequestDataModel;
	}
}