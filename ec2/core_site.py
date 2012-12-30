import xml.dom.minidom
import os

def addProperty(doc, properties, propertyName, propertyValue):
  property = doc.createElement("property")
  name = doc.createElement("name")
  nameText = doc.createTextNode(propertyName)
  value = doc.createElement("value")
  valueText = doc.createTextNode(propertyValue)

  name.appendChild(nameText)
  value.appendChild(valueText)
  property.appendChild(name)
  property.appendChild(value)
  properties.appendChild(property)

def addCredentials(filename):
  doc = xml.dom.minidom.parse(filename)
  properties = doc.childNodes[2]
  addProperty(doc, properties, 'fs.s3n.awsAccessKeyId', os.getenv('AWS_ACCESS_KEY_ID'))
  addProperty(doc, properties, 'fs.s3n.awsSecretAccessKey', os.getenv('AWS_SECRET_ACCESS_KEY'))
  doc.writexml(open(filename, "w"))
