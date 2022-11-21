import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_bottom/controller/base_controller.dart';

class ProductController extends BaseController {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  final productFormKey = GlobalKey<FormState>();

  List categoryList = ["mobile", "food", "wear", "laptop"];

  var selectedItem = "".obs;
  var category = "".obs;

  RxString productImg = "".obs;
  final ImagePicker imagePicker = ImagePicker();

  // XFile? pickedImage;
  final pickedImage = Rxn<XFile>();

  RxBool isUpload = true.obs;
  RxString imageUrl = "".obs;
  RxString productId = "".obs;

  @override
  void onInit() {
    clearController();
    isEdit.value = Get.arguments['editProduct'];
    imageUrl.value = Get.arguments['proImage'].toString();
    productId.value = Get.arguments['productId'].toString();
    nameController.text = Get.arguments['proName'].toString();
    priceController.text = Get.arguments['proPrice'].toString();
    selectedItem.value = Get.arguments['proCategory'].toString();
    descController.text = Get.arguments['proDescription'].toString();
    print(Get.arguments['proImage']);
    print(Get.arguments['proName']);
    print(Get.arguments['proPrice']);
    print(Get.arguments['proCategory']);
    print(Get.arguments['proDescription']);
    print("Product Id : ${productId.value}");
    super.onInit();
  }

  void clearController() {
    nameController.clear();
    descController.clear();
    priceController.clear();
  }

  final currenUserId = FirebaseAuth.instance.currentUser!.uid;





  //add new product
  Future<void> addProduct(context) async {
    await uploadImage();
    if (productFormKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection("products").add({
        "product_name": nameController.text,
        "description": descController.text,
        "price": priceController.text,
        "category": selectedItem.value.toString(),
        "imageUrl": imageUrl.value.toString(),
      }).then((value) {
        //uploadImage();
        print("Added Product Value ${value.id}");
        value.set({'productID': value.id}, SetOptions(merge: true));
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Container(color: Colors.blue, child: const Text("Flutter!!")),
              content: const Text("Product Added Successfully..."),
            );
          },
        );
        clearController();
        Future.delayed(const Duration(seconds: 3), () {
          //Get.offAndToNamed(HomeScreen.pageId);
          Get.back();
          Get.back();
        });
      });
    }
  }

  //update product
  Future updateProduct() async {
    loader.value = true;
    productFormKey.currentState!.save();
    if (productFormKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection("products").doc(productId.value).update({
        "product_name": nameController.text,
        "description": descController.text,
        "price": priceController.text,
        "category": selectedItem.value.toString(),
        "imageUrl": imageUrl.value.toString(),
      });
      Future.delayed(const Duration(seconds: 5), () {
        Get.back();
        loader.value = false;
      });
      print("Update data ");
    }
  }

  //delete product
  Future deleteProduct() async {
    FirebaseFirestore.instance.collection("products").doc(productId.value).delete();
  }

  // Future selectFile()async{
  //   final res= await FilePicker.platform.pickFiles();
  // }

  Future selectImage() async {
    pickedImage.value =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage.value != null) {
      print('picked Image path: ${pickedImage.value!.path} ');
      productImg.value = pickedImage.value!.path;
      isUpload.value = false;
    }
  }

  Future uploadImage() async {
    final path = 'productImages/${nameController.value.text} ${DateTime.now()}';
    print(path);
    final file = File(pickedImage.value!.path);
    print("File $file");

    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);

    imageUrl.value = await ref.getDownloadURL();
    print("download Url : $imageUrl.value");

    isUpload.value = false;
  }
}
