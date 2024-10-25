final url = 'https://back-deliverys.onrender.com/api';

//log&reg
final registerion = url + "/users/registration";
final login = url + "/users/login";

//user
final getUserById = url + "/users";

//rider
final getAvailableOrders = url + "/orders/rider/available";
final acceptOrder = url + "/orders/rider";
final uploadDeliveryImages = url + "/orders/rider";
final completeDelivery = url + "/orders/rider";
final updateOrderStatus = url + "/orders/rider";

//location
final updateLocation = url + "/location/update";
final getOrderLocations = url + "/location/order-locations";
final getRiderLocation = url + "/location/rider";

//food
final getAllFood = url + "/foods";
final getFoodByName = url + "/foods/name";

//order
final cre_Order = url + "/orders";
