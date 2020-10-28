/*  Defines a small utility class that is used to format requests properly for the json:api
    specifications.
 */
class JsonApiRequest {
  /*  forms a FormData object to be compliant with the json:api specification.
  */
  static fromFormData(entityType, id, formData) {
    const attributes = {};
    for (var data of formData.entries()) {
      attributes[data[0]] = data[1];
    }

    const jsonData = {
      type: entityType,
      data: {
        attributes: attributes
      }
    }

    if (id) {
      jsonData.id = id
    }

    return jsonData;
  }

  /*  formats a plain object to be compliant wih the json:api specification.
  */
 static fromAttributesObject(entityType, id, attributes) {
    const jsonData = {
      type: entityType,
      data: {
        attributes: attributes
      }
    }

    if (id) {
      jsonData.id = id
    }

    return jsonData;
  }}