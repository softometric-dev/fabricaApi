<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};

class DeleteBrandRequestDataModel extends ApiRequestDataModel
{

    public $brandToDelete;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $brandToDelete = $this->brandToDelete;

        // Validate mandatory inputs
        if (empty($brandToDelete) || empty($brandToDelete->brandId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'brandId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteBrandRequestDataModel = new DeleteBrandRequestDataModel();

        if ($jsonData !== null) {
            $brandToDelete = $jsonData->brandToDelete ?? null;
            if ($brandToDelete !== null) {
                $brandDataModel = BrandDataModel::fromJson($brandToDelete);
                $deleteBrandRequestDataModel->brandToDelete = $brandDataModel;
            }
        }

        return $deleteBrandRequestDataModel;
    }

}