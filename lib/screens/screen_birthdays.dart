
import 'package:birthday_app/database/birthdaysDB.dart';
import 'package:birthday_app/models/person.dart';
import 'package:birthday_app/screens/screen_add_person.dart';
import 'package:birthday_app/screens/screen_person_overview.dart';
import 'package:birthday_app/utils/enums.dart';
import 'package:birthday_app/utils/helpers/save_person_controller.dart';
import 'package:birthday_app/utils/methods.dart';
import 'package:birthday_app/utils/providers.dart';
import 'package:birthday_app/utils/services/local_notif_service.dart';
import 'package:birthday_app/utils/styling.dart';
import 'package:birthday_app/widgets/failure_snackbar.dart';
import 'package:birthday_app/widgets/success_snackbar.dart';
import 'package:birthday_app/widgets/vertical_space.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';

class BirthdaysScreen extends ConsumerStatefulWidget {
  const BirthdaysScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends ConsumerState<BirthdaysScreen> {

  late Size screenSize;
  LoadingStatus loadingStatus = LoadingStatus.loading;
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    loadPeople();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }
  
  Future<void> loadPeople() async {

    setState(() {
      loadingStatus = LoadingStatus.loading;
    });

    try{

      List<Person> people = await BirthdaysDB.instance.getAllPeopleFromDB();
      ref.read(personNotifierProvider.notifier).setPersonList(people);

      loadingStatus = LoadingStatus.succeeded;
    }
    catch(exp){
      loadingStatus = LoadingStatus.failed;
    }

    if(mounted){
      setState(() {});
    }
  }

  String getRemainingTimeText(Person person){

    int remainingDays = person.nextBirthDate!.difference(DateTime.now()).inDays;

    if(remainingDays < 30){
      return "$remainingDays\nGün";
    }
    else{
      int remainingMonths = (remainingDays / 30).floor();
      return "$remainingMonths\nAy";
    }
  }

  Widget ScreenBody(){

    switch (loadingStatus) {
      case LoadingStatus.loading:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Lottie.asset(
              "assets/lotties/presents_loading.json",
              repeat: true
            ),
          )
        );
      case LoadingStatus.failed:
        return Center(
          child: Container(),
        );
      case LoadingStatus.succeeded:

        List<Person> people = ref.watch(personNotifierProvider);
        people.sort((person1, person2) {
          DateTime today = DateTime.now();
          return person1.nextBirthDate!.difference(today).inDays - person2.nextBirthDate!.difference(today).inDays;
        });

        return people.isEmpty ? 
          SizedBox(
            width: screenSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.asset(
                    "assets/images/add_person.png"
                  ),
                ),
                VerticalSpace(12),
                Text(
                  "Henüz listede kimse yok!",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: TextFonts.nunitoSans.fontName
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ) : 
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                collapsedHeight: 0,
                toolbarHeight: 0,
                expandedHeight: screenSize.height * 0.25,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    "assets/images/balloons.jpg",
                    fit: BoxFit.fitWidth,
                  )
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    
                    Person person = people[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Slidable(
                        key: ValueKey(person.personID),
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: const ScrollMotion(),
                          dragDismissible: true,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {

                                ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
                                bool res = await BirthdaysDB.instance.deletePersonFromDB(person.personID!);

                                if(res){
                                  LocalNotifService.instance.cancelScheduledNotification(person.personID!);
                                  ref.read(personNotifierProvider.notifier).removePersonFromList(person.personID!);
                                  messengerState..clearSnackBars()..showSnackBar(
                                    SuccessSnackbar("Kişi silindi")
                                  );
                                }
                                else{
                                  messengerState..clearSnackBars()..showSnackBar(
                                    FailureSnackbar("Bir hata meydana geldi")
                                  );
                                }

                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: "Sil",
                              borderRadius: BorderRadius.circular(4),
                            )
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              getBoxShadow(person)
                            ]
                          ),
                          child: ListTile(
                            dense: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => PersonOverviewScreen(person))
                              );
                            },
                            onLongPress: () async {

                              if(kDebugMode){
                                var pendings = await LocalNotifService.instance.getPendingNotifs();
                                for (var pending in pendings) {
                                  print(pending.payload);
                                }
                              }
                            },
                            horizontalTitleGap: 12,
                            minLeadingWidth: 0,
                            contentPadding: const EdgeInsets.only(left: 6, right: 16, top: 6, bottom: 6),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.yellow.shade700,
                              backgroundImage: AssetImage(
                                person.avatarPath
                              ),
                            ),
                            title: Text(
                              person.fullname,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: TextFonts.nunitoSans.fontName
                              ),
                            ),
                            subtitle: Text(
                              getBirthDayInfoText(person),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                fontFamily: TextFonts.nunitoSans.fontName
                              ),
                            ),
                            trailing: Person.isTodayBirthday(person) ? Icon(Icons.cake, color: Colors.yellow.shade700,): Text(
                              getRemainingTimeText(person),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                fontFamily: TextFonts.nunitoSans.fontName
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: people.length
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          );
    }
  }
  
  BoxShadow getBoxShadow(Person person){
    
    if(Person.isTodayBirthday(person)){
      return BoxShadow(
        color: Colors.yellow.shade700,
        blurRadius: 5,
        spreadRadius: 0.25
      );
    }

    return const BoxShadow(
      color: Colors.grey,
      blurRadius: 0.5,
      spreadRadius: 0.25
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 10,
        backgroundColor: appBarPink,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Birthdays",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: TextFonts.meowScript.fontName
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SaveUserController(child: AddPersonScreen(screenMode: ScreenMode.create,)))
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
      body: ScreenBody(),
    );
  }
}
