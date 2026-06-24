function checkForMIMEType(response) {
  var blob;
  if (response.mimetype == 'pdf') {
    blob = converBase64toBlob(response.content, 'application/pdf');
  } else if (response.mimetype == 'doc') {
    blob = converBase64toBlob(response.content, 'application/msword'); 
    /*Find the content types for different format of file at http://www.freeformatter.com/mime-types-list.html*/
  }
  var blobURL = URL.createObjectURL(blob);
  window.open(blobURL);
}
function converBase64toBlob(content, contentType) {
  contentType = contentType || '';
  var sliceSize = 512;
  var byteCharacters = window.atob(content); //method which converts base64 to binary
  var byteArrays = [
  ];
  for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
    var slice = byteCharacters.slice(offset, offset + sliceSize);
    var byteNumbers = new Array(slice.length);
    for (var i = 0; i < slice.length; i++) {
      byteNumbers[i] = slice.charCodeAt(i);
    }
    var byteArray = new Uint8Array(byteNumbers);
    byteArrays.push(byteArray);
  }
  var blob = new Blob(byteArrays, {
    type: contentType
  }); //statement which creates the blob
  return blob;
}