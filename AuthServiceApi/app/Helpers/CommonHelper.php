<?php

if (!function_exists('isNullOrEmpty1')) {
    function isNullOrEmpty1($object, $properties = null)
    {
        $isNullOrEmpty = false;
        if ($object === null) {
            $isNullOrEmpty = true;
        } else {
            if (is_array($object)) {
                if (empty($object)) {
                    $isNullOrEmpty = true;
                } else if ($properties !== null && !empty($properties)) {
                    foreach ($object as $row) {
                        foreach ($properties as $property) {
                            if (property_exists($row, $property)) {
                                if ($row->$property !== null) {
                                    if (is_string($row->$property)) {
                                        if (empty(trim($row->$property))) {
                                            $isNullOrEmpty = true;
                                            break;
                                        }
                                    }
                                } else {
                                    $isNullOrEmpty = true;
                                    break;
                                }
                            } else {
                                $isNullOrEmpty = true;
                                break;
                            }
                        }
                        if ($isNullOrEmpty) {
                            break;
                        }
                    }
                }
            } else if (is_string($object)) {
                $isNullOrEmpty = empty(trim($object));
            } else {
                $isNullOrEmpty = empty($object);
            }
        }
        return $isNullOrEmpty;
    }
}

if (!function_exists('isNullOrEmpty')) {
    function isNullOrEmpty($value, $properties = null)
    {
        $isNullOrEmpty = $value === null || (is_string($value) && trim($value) === '') ||
            (is_array($value) && empty($value)) || (is_object($value) && empty((array)$value));

        if (!$isNullOrEmpty && is_array($value) && $properties !== null) {
            foreach ($value as $row) {
                foreach ($properties as $property) {
                    if (property_exists($row, $property)) {
                        if ($row->$property !== null) {
                            $isNullOrEmpty = isNullOrEmpty($row->$property);
                        } else {
                            $isNullOrEmpty = true;
                            break;
                        }
                    } else {
                        $isNullOrEmpty = true;
                        break;
                    }
                }
                if ($isNullOrEmpty) {
                    break;
                }
            }
        }

        return $isNullOrEmpty;
    }
}

if (!function_exists('getFileFullPath')) {
    function getFileFullPath($path, $name, $extension = '')
    {
        if (isNullOrEmpty($path) || isNullOrEmpty($name)) {
            throw new \Exception("Path or Name cannot be empty or null");
        }

        $baseName = basename($path);
        $extFromFileName = getExtensionFromFileName($name);
        $fileName = isNullOrEmpty($extFromFileName) && !isNullOrEmpty($extension) ? $name . '.' . $extension : $name;

        $directory = strcasecmp(trim($baseName), trim($fileName)) === 0 ? dirname($path) : $path;

        $fileFullPath = $directory . '/' . $fileName;
        return $fileFullPath;
    }
}

if (!function_exists('getExtensionFromFileName')) {
    function getExtensionFromFileName($name)
    {
        return pathinfo($name, PATHINFO_EXTENSION);
    }
}

