'use strict';

var arrayUnique = function(array) {
  return array.reduce(function(previousValue, currentValue) {
    if (previousValue.indexOf(currentValue) < 0) previousValue.push(currentValue);
    return previousValue;
  }, []);
};

exports.arrayUnique = arrayUnique;
