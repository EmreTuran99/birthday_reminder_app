
import 'package:birthday_app/database/birthdaysDB.dart';
import 'package:birthday_app/models/person.dart';
import 'package:birthday_app/utils/enums.dart';
import 'package:birthday_app/utils/helpers/save_person_controller.dart';
import 'package:birthday_app/utils/methods.dart';
import 'package:birthday_app/utils/providers.dart';
import 'package:birthday_app/utils/services/local_notif_service.dart';
import 'package:birthday_app/utils/styling.dart';
import 'package:birthday_app/utils/values.dart';
import 'package:birthday_app/widgets/failure_snackbar.dart';
import 'package:birthday_app/widgets/horizontal_space.dart';
import 'package:birthday_app/widgets/success_snackbar.dart';
import 'package:birthday_app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPersonScreen extends ConsumerStatefulWidget {
  const AddPersonScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {

  late Size screenSize;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  Future<bool> notifWarning() async {

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Container(
            padding: const EdgeInsets.all(6),
            color: Colors.white,
            child: const Center(
              child: Icon(Icons.logout_outlined, size: 64, color: Colors.red),
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: "Bildirim İzni Verilmedi!",
                style: TextStyle(fontFamily: TextFonts.nunitoSans.fontName, fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              TextSpan(
                text: "\n\nOluşturulan kişi için bildirim gösterilemeyecek, yine de devam edilsin mi?",
                style: TextStyle(fontFamily: TextFonts.nunitoSans.fontName, fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black),
              )
            ]),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.blue)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "VAZGEÇ",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue, fontFamily: TextFonts.nunitoSans.fontName, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "ÇIK",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: TextFonts.nunitoSans.fontName, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> savePerson() async {

    bool isValid = SaveUserController.of(context).saveUserFormKey.currentState?.validate() ?? false;

    if(!isValid){
      return;
    }

    NavigatorState navState = Navigator.of(context);
    ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);

    SaveUserController saveUserCtrl = SaveUserController.of(context);
    DateTime birthDate = saveUserCtrl.selectedBirthDate!;

    var notifPermStatus = await Permission.notification.request();

    print(notifPermStatus);

    if(notifPermStatus.isPermanentlyDenied || notifPermStatus.isDenied){
      // show user warning
      /* bool shouldContinue = await notifWarning();
      if(!shouldContinue){
        return;
      } */
    }
    else{
      // permission granted, no problem
    }

    Person personToSave = Person(
      personID: null,
      fullname: saveUserCtrl.ctrlFullname.text,
      birthDate: birthDate,
      avatarPath: saveUserCtrl.isAvatarMale ? maleAvatarPath : femaleAvatarPath,
      zodiacSign: ZodiacSignExtension.getZodiacSignFromDate(saveUserCtrl.selectedBirthDate!),
      notes: saveUserCtrl.ctrlNotes.text.isEmpty ? null : saveUserCtrl.ctrlNotes.text,
      nextBirthDate: Person.findNextBirthate(birthDate)
    );

    int personID = await BirthdaysDB.instance.createNewPerson(personToSave);
    if(personID != 0){
      try{
        LocalNotifService.instance.setScheduledNotifs(
          personID,
          "Pastayı ve hediyeleri hazırlayın!",
          "Bugün ${saveUserCtrl.ctrlFullname.text} adlı kişinin doğum günü!",
          Person.findNextBirthate(birthDate).toIso8601String(),
          scheduledDate: Person.findNextBirthate(birthDate),
        );
        print("notif created");
      }
      catch(exp){
        print(exp);
      }
      ref.read(personNotifierProvider.notifier).addPersonToList(personToSave.copyWith(personID: personID));
      messengerState..clearSnackBars()..showSnackBar(
        SuccessSnackbar("Kişi kaydedildi!")
      );
      navState.pop();
    }
    else{
      messengerState..clearSnackBars()..showSnackBar(
        FailureSnackbar("Hata meydana geldi!")
      );
    }
  }

  Widget PersonAvatar(){

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 10,
          shape: const CircleBorder(),
          child: CircleAvatar(
            backgroundColor: Colors.yellow.shade700,
            radius: 56,
            backgroundImage: AssetImage(
              SaveUserController.of(context).isAvatarMale ? maleAvatarPath : femaleAvatarPath
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                SaveUserController.of(context).isAvatarMale = !SaveUserController.of(context).isAvatarMale;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appBarPink,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0)
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        )
      ],
    );
  }

  Widget FullnameTextField(){

    return TextFieldWithIcon(
      Icons.account_circle_rounded,
      TextFormField(
        controller: SaveUserController.of(context).ctrlFullname,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        maxLines: 1,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: UnderlineInputBorder(),
          isDense: true,
          hintText: "Ad ve soyad",
        ),
        validator: (value) => value == null || value.isEmpty ? "Bu alan boş bırakılamaz" : null
      )
    );
  }

  Widget BirthdateTextField(){

    return TextFieldWithIcon(
      Icons.date_range_rounded,
      GestureDetector(
        onTap: () async {

          FocusManager.instance.primaryFocus?.unfocus();

          await showDatePicker(
            context: context, 
            initialDate: DateTime.now(), 
            firstDate: DateTime(1900, 1, 1), 
            lastDate: DateTime.now()
          ).then((selectedDate) {

            if(selectedDate == null) {
              return;
            }

            SaveUserController.of(context).selectedBirthDate = selectedDate;
            SaveUserController.of(context).ctrlBirthdate.text = formattedBirthDate(selectedDate);
          });
        },
        child: AbsorbPointer(
          absorbing: true,
          child: TextFormField(
            controller: SaveUserController.of(context).ctrlBirthdate,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            maxLines: 1,
            readOnly: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: UnderlineInputBorder(),
              isDense: true,
              hintText: "Doğum tarihi girin"
            ),
            validator: (value) => value == null || value.isEmpty ? "Bu alan boş bırakılamaz" : null
          ),
        ),
      )
    );
  }

  Widget NotesTextField(){

    return TextFieldWithIcon(
      Icons.notes_rounded,
      TextFormField(
        controller: SaveUserController.of(context).ctrlNotes,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLines: 1,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: UnderlineInputBorder(),
          isDense: true,
          hintText: "Notlar",
        ),
      )
    );
  }

  Widget TextFieldWithIcon(IconData iconData, Widget textFormField){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HorizontalSpace(24),
        Icon(iconData, size: 32, color: Colors.black),
        HorizontalSpace(6),
        Expanded(child: textFormField),
        HorizontalSpace(24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        title: Text(
          "Yeni Kişi Ekle",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: TextFonts.nunitoSans.fontName,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              savePerson();
            },
            icon: const Icon(
              Icons.save,
              color: Colors.black,
              size: 24,
            ),
          )
        ],
      ),
      body: SizedBox(
        width: screenSize.width,
        child: Form(
          key: SaveUserController.of(context).saveUserFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VerticalSpace(48),
              PersonAvatar(),
              VerticalSpace(24),
              FullnameTextField(),
              VerticalSpace(24),
              BirthdateTextField(),
              VerticalSpace(24),
              NotesTextField(),
              VerticalSpace(24),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}