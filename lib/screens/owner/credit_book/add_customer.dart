import 'package:WSHCRD/common/algolia_text_field.dart';
import 'package:WSHCRD/utils/global.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AddCustomer extends StatefulWidget {
  static const routeName = 'AddCustomer';

  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  late Future<List<Contact>> contactsFuture;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController internationalPhoneNumberController =
      TextEditingController();
  bool nameAdded = false;

  @override
  void initState() {
    super.initState();
    contactsFuture = ContactsService.getContacts(withThumbnails: false);
    showLoadingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 30, right: 10, left: 10),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text("ADD NEW CUSTOMER",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              width: EdgeInsetsGeometry.infinity.along(Axis.horizontal),
              padding: const EdgeInsets.all(8),
              color: HexColor("#f5f5f5"),
              child: const Text(
                "Phonebook Contacts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<Iterable<Contact>>(
                future: contactsFuture,
                builder: (context, snapshot) {
                  closeLoadingScreen();
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    List<Contact> contacts = snapshot.data!
                        .where((element) => element.givenName != null)
                        .toList();
                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              nameController.text = contacts[index].givenName!;
                              phoneNumberController.text = (contacts[index]
                                      .phones!
                                      .isNotEmpty
                                  ? contacts[index].phones!.toList()[0].value
                                  : '')!;
                              addNewCustomer(context, nameController.text,
                                  phoneNumberController.text);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  (contacts[index].avatar != null &&
                                          contacts[index].avatar!.isNotEmpty)
                                      ? CircleAvatar(
                                          backgroundImage: Image.memory(
                                            contacts[index].avatar!,
                                          ).image,
                                        )
                                      : CircleAvatar(
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: Text(
                                                  contacts[index].givenName![0],
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            decoration: BoxDecoration(
                                              color: kColorSlabs[
                                                  index % kColorSlabs.length],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Text(contacts[index].givenName ?? "")
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Expanded(child: Container());
                }),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: AlgoliaTextField(
                          prefixIcon: const Icon(Icons.person_outline),
                          controller: nameController,
                          onChanged: () {
                            if (nameController.text != '') {
                              contactsFuture = ContactsService.getContacts(
                                  query: nameController.text,
                                  withThumbnails: false);
                            } else {
                              contactsFuture = ContactsService.getContacts(
                                  withThumbnails: false);
                            }
                            setState(() {});
                          },
                          label: 'Name',
                        )),
                        const SizedBox(
                          width: 14,
                        ),
                        Visibility(
                          visible: !nameAdded,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: InkWell(
                            onTap: () {
                              if (nameController.text.isEmpty) {
                                Global.showToastMessage(
                                    context: context, msg: 'name is mandatory');
                              } else {
                                setState(() {
                                  nameAdded = true;
                                });
                              }
                            },
                            child: const CircleAvatar(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              ),
                              backgroundColor: Color(0xFF18d29f),
                            ),
                          ),
                        )
                      ],
                    ),
                    Visibility(
                      visible: nameAdded,
                      child: const SizedBox(
                        height: 28,
                      ),
                    ),
                    Visibility(
                      visible: nameAdded,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: InternationalPhoneNumberInput(
                                //selectorType: PhoneInputSelectorType.DIALOG,
                                isEnabled: true,
                                onInputChanged: (number) {
                                  phoneNumberController.text =
                                      number.phoneNumber!;
                                },
                                onInputValidated: (validated) {
                                  print(validated);
                                  if (validated) {
                                    internationalPhoneNumberController.text =
                                        phoneNumberController.text;
                                  } else {
                                    internationalPhoneNumberController.text =
                                        '';
                                  }
                                },
                                inputDecoration:
                                    const InputDecoration.collapsed(
                                        hintText: 'Enter mobile number',
                                        hintStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Visibility(
                            visible: true,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: CircleAvatar(
                              child: InkWell(
                                onTap: () async {
                                  if ((phoneNumberController.text.isEmpty ||
                                          internationalPhoneNumberController
                                              .text.isNotEmpty) &&
                                      nameController.text.isNotEmpty) {
                                    addNewCustomer(context, nameController.text,
                                        phoneNumberController.text);
                                  } else if (phoneNumberController
                                          .text.isNotEmpty &&
                                      internationalPhoneNumberController
                                          .text.isEmpty) {
                                    Global.showToastMessage(
                                        context: context,
                                        msg: 'Invalid Number');
                                  }
                                },
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.black,
                                ),
                              ),
                              backgroundColor: const Color(0xFF18d29f),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
