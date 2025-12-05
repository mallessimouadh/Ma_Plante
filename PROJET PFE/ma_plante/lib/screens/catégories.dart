import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  final List<String> _categories = ['Tous les articles', 'Légumes', 'Fruits'];

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        backgroundColor: const Color(0xFF0A331F),
      ),
      body: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.only(top: 16, bottom: 10),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _buildCategoryTabs(),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return ItemGridView(category: category);
              }).toList(),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0C3C26),
    );
  }

  List<Widget> _buildCategoryTabs() {
    return _categories.map((category) {
      final isSelected = _categories.indexOf(category) == _selectedTabIndex;
      return Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? Colors.green : Colors.transparent,
          ),
          child: Center(child: Text(category)),
        ),
      );
    }).toList();
  }
}

class ItemGridView extends StatelessWidget {
  final String category;

  const ItemGridView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = getItemsByCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: items[index]);
      },
    );
  }

  List<CatalogItem> getItemsByCategory(String category) {
    final vegetables = [
      CatalogItem(
        id: 'legume_1',
        name: 'Ail',
        imagePath: 'assets/images/légumes/ail.jpg',
        category: 'Légumes',
        scientificName: 'Allium sativum',
        origin: 'Asie centrale',
        description:
            'L\'ail est une plante bulbeuse de la famille des Amaryllidacées, cultivée pour ses propriétés aromatiques et gustatives ainsi que pour ses propriétés médicinales.',
        growingInfo:
            'Plantez les gousses d\'ail à l\'automne ou au début du printemps dans un sol bien drainé et ensoleillé. Espacez les gousses de 15 cm et plantez-les à 5 cm de profondeur, la pointe vers le haut.',
        harvestInfo:
            'Récoltez l\'ail lorsque les feuilles commencent à jaunir et à sécher, généralement en été. Laissez sécher les bulbes dans un endroit chaud et bien ventilé pendant 2-3 semaines.',
        nutritionalValue:
            'Riche en allicine, un composé aux propriétés antibactériennes et antifongiques. Contient également des vitamines B6 et C, du manganèse et des antioxydants.',
        commonProblems:
            'Peut être affecté par la pourriture du bulbe, la moisissure ou les thrips. Une humidité excessive peut provoquer des maladies fongiques.',
        tips:
            'Ne pas arroser excessivement l\'ail pour éviter la pourriture. Arrêtez l\'arrosage 2-3 semaines avant la récolte pour permettre aux bulbes de sécher.',
      ),
      CatalogItem(
        id: 'legume_2',
        name: 'Aubergine',
        imagePath: 'assets/images/légumes/aubergine.jpg',
        category: 'Légumes',
        scientificName: 'Solanum melongena',
        origin: 'Inde et Asie du Sud-Est',
        description:
            'L\'aubergine est un légume-fruit de la famille des Solanacées, appréciée pour sa chair tendre et sa polyvalence culinaire.',
        growingInfo:
            'Semez les graines à l\'intérieur 8-10 semaines avant le dernier gel. Transplantez dans un sol riche et bien drainé après tout risque de gel. Préfère un plein soleil et des températures chaudes.',
        harvestInfo:
            'Récoltez les aubergines lorsque leur peau est brillante et que la chair cède légèrement à la pression. Coupez la tige avec des ciseaux ou un couteau pour éviter d\'endommager la plante.',
        nutritionalValue:
            'Faible en calories mais riche en fibres. Contient des vitamines B1, B6, potassium et manganèse. Les anthocyanes présentes dans la peau ont des propriétés antioxydantes.',
        commonProblems:
            'Sensible aux pucerons, acariens, altises et au mildiou. La pourriture des fruits peut survenir par temps humide.',
        tips:
            'Utilisez un paillis pour maintenir l\'humidité et réduire les mauvaises herbes. Soutenez les plantes avec des tuteurs pour éviter que les tiges ne se cassent sous le poids des fruits.',
      ),
      CatalogItem(
        id: 'legume_3',
        name: 'Brocoli',
        imagePath: 'assets/images/légumes/brocolli.jpg',
        category: 'Légumes',
        scientificName: 'Brassica oleracea var. italica',
        origin: 'Région méditerranéenne, Italie',
        description:
            'Le brocoli est un légume crucifère caractérisé par sa tête verte dense composée de bouquets de fleurs immatures.',
        growingInfo:
            'Semez directement en pleine terre au printemps ou à la fin de l\'été pour une récolte d\'automne. Préfère un sol riche en matière organique et bien drainé. Arrosez régulièrement.',
        harvestInfo:
            'Récoltez la tête centrale lorsqu\'elle est ferme et bien développée, mais avant que les fleurs ne s\'ouvrent. Après la récolte principale, de petites pousses latérales se développeront pour des récoltes supplémentaires.',
        nutritionalValue:
            'Excellente source de vitamines C et K, folate, et fibres. Contient des composés sulforaphane aux propriétés anticancéreuses.',
        commonProblems:
            'Peut être attaqué par les chenilles, pucerons et altises. Sensible à la hernie des crucifères et à l\'oïdium.',
        tips:
            'Pour éviter la montée en graines prématurée, plantez à la bonne saison et évitez les stress thermiques. Une couche de paillis aide à garder le sol frais pendant les mois chauds.',
      ),
      CatalogItem(
        id: 'legume_4',
        name: 'Carotte',
        imagePath: 'assets/images/légumes/carotte.jpg',
        category: 'Légumes',
        scientificName: 'Daucus carota subsp. sativus',
        origin: 'Asie centrale',
        description:
            'La carotte est une plante bisannuelle de la famille des Apiacées, cultivée pour sa racine pivotante charnue, riche en carotène.',
        growingInfo:
            'Semez directement en pleine terre dans un sol léger, sablonneux et profond, sans pierres. Semez de façon échelonnée pour des récoltes continues. Gardez le sol humide jusqu\'à la germination.',
        harvestInfo:
            'Les carottes sont prêtes à être récoltées lorsque leur diamètre atteint environ 2,5 cm au sommet. Tirez doucement sur les fanes en tenant près de la base, ou aidez-vous d\'une fourche pour les sols compacts.',
        nutritionalValue:
            'Riche en bêta-carotène (précurseur de la vitamine A), vitamines K, B6 et fibres. Excellente source d\'antioxydants.',
        commonProblems:
            'Peut être affectée par la mouche de la carotte, les nématodes et diverses maladies fongiques. Le fendillement des racines survient souvent lors d\'arrosages irréguliers.',
        tips:
            'Éclaircissez les plants pour permettre un bon développement des racines. Évitez les sols récemment fumés qui peuvent provoquer des racines fourchues.',
      ),
      CatalogItem(
        id: 'legume_5',
        name: 'Chou',
        imagePath: 'assets/images/légumes/chou.jpg',
        category: 'Légumes',
        scientificName: 'Brassica oleracea var. capitata',
        origin: 'Europe méditerranéenne',
        description:
            'Le chou est une plante potagère de la famille des Brassicacées, caractérisée par des feuilles lisses formant une tête compacte.',
        growingInfo:
            'Semez en intérieur 6-8 semaines avant la dernière gelée ou directement en pleine terre. Transplantez dans un sol riche, bien drainé et légèrement alcalin. Nécessite un espacement adéquat pour le développement des têtes.',
        harvestInfo:
            'Récoltez quand les têtes sont fermes et ont atteint leur taille mature. Coupez à la base avec un couteau tranchant, en laissant quelques feuilles extérieures pour protéger la tête.',
        nutritionalValue:
            'Excellente source de vitamines C et K, riche en fibres et en antioxydants. Contient des composés soufrés bénéfiques pour la santé.',
        commonProblems:
            'Sensible aux chenilles, pucerons, limaces et escargots. Peut être affecté par la hernie des crucifères et le mildiou.',
        tips:
            'Pratiquez la rotation des cultures pour éviter les maladies. Un paillage autour des plants aide à conserver l\'humidité et à réduire les mauvaises herbes.',
      ),
      CatalogItem(
        id: 'legume_6',
        name: 'Concombre',
        imagePath: 'assets/images/légumes/concombre.jpg',
        category: 'Légumes',
        scientificName: 'Cucumis sativus',
        origin: 'Inde',
        description:
            'Le concombre est une plante potagère rampante de la famille des Cucurbitacées, cultivée pour ses fruits cylindriques consommés comme légumes.',
        growingInfo:
            'Semez directement après tout risque de gel, ou démarrez à l\'intérieur 3-4 semaines avant. Préfère un sol riche, humide mais bien drainé, et plein soleil. Peut être cultivé en treillis pour économiser de l\'espace.',
        harvestInfo:
            'Récoltez régulièrement lorsque les fruits atteignent 15-20 cm de long pour les variétés standard. Coupez la tige au lieu de tirer sur le fruit pour éviter d\'endommager la plante.',
        nutritionalValue:
            'Composé principalement d\'eau (96%), faible en calories. Source de vitamines K, C, potassium et magnésium. La peau contient de la lutéine bénéfique pour la santé oculaire.',
        commonProblems:
            'Peut être affecté par le mildiou, l\'oïdium et diverses maladies fongiques. Sensible aux coléoptères du concombre, pucerons et tétranyques.',
        tips:
            'Une récolte régulière stimule la production de nouveaux fruits. Évitez de mouiller le feuillage lors de l\'arrosage pour prévenir les maladies fongiques.',
      ),
      CatalogItem(
        id: 'legume_7',
        name: 'Okra',
        imagePath: 'assets/images/légumes/Okra.jpg',
        category: 'Légumes',
        scientificName: 'Abelmoschus esculentus',
        origin: 'Afrique et Asie du Sud',
        description:
            'L\'okra ou gombo est une plante tropicale annuelle dont on consomme les fruits immatures, connus pour leur texture légèrement gluante utilisée pour épaissir les soupes et ragoûts.',
        growingInfo:
            'Semez directement lorsque les sols sont bien réchauffés (au moins 20°C). Nécessite un sol fertile et bien drainé, en plein soleil. Arrosez régulièrement mais évitez l\'excès d\'humidité.',
        harvestInfo:
            'Récoltez les gousses jeunes, lorsqu\'elles mesurent 5-10 cm de long, généralement 4-6 jours après la floraison. Utilisez des gants pour la récolte car certaines variétés ont des poils qui peuvent irriter la peau.',
        nutritionalValue:
            'Bonne source de vitamines C et K, folate, magnésium et fibres. Contient des antioxydants bénéfiques comme la quercétine.',
        commonProblems:
            'Peut être affecté par la fusariose, les nématodes, les pucerons et les tétranyques. Sensible à la pourriture des racines dans les sols trop humides.',
        tips:
            'La récolte fréquente encourage une production continue. Évitez de laisser les gousses trop mûrir sur la plante car elles deviennent fibreuses et diminuent la production globale.',
      ),
      CatalogItem(
        id: 'legume_8',
        name: 'Oignon',
        imagePath: 'assets/images/légumes/onion.jpg',
        category: 'Légumes',
        scientificName: 'Allium cepa',
        origin: 'Asie centrale',
        description:
            'L\'oignon est une plante bulbeuse de la famille des Amaryllidacées, cultivée pour son bulbe à saveur piquante utilisé comme condiment et légume dans de nombreuses cuisines du monde.',
        growingInfo:
            'Semez directement en pleine terre au début du printemps ou plantez des bulbilles. Préfère un sol bien drainé et ensoleillé. Évitez les sols trop riches en azote qui favorisent le développement foliaire au détriment des bulbes.',
        harvestInfo:
            'Récoltez lorsque les feuilles commencent à jaunir et à se coucher naturellement. Laissez sécher les bulbes au soleil pendant quelques jours avant de les stocker dans un endroit frais, sec et bien ventilé.',
        nutritionalValue:
            'Contient de la quercétine aux propriétés anti-inflammatoires, ainsi que des vitamines C, B6 et des minéraux comme le potassium et le manganèse.',
        commonProblems:
            'Peut être affecté par la pourriture du bulbe, le mildiou et la mouche de l\'oignon. Les thrips peuvent également causer des dommages aux feuilles.',
        tips:
            'Arrêtez l\'arrosage une fois que les bulbes commencent à mûrir. Un bon espacement entre les plants favorise le développement de gros bulbes et réduit les risques de maladies.',
      ),
      CatalogItem(
        id: 'legume_9',
        name: 'Pois Cultivé',
        imagePath: 'assets/images/légumes/pois cultivé.jpg',
        category: 'Légumes',
        scientificName: 'Pisum sativum',
        origin: 'Moyen-Orient et Méditerranée orientale',
        description:
            'Le pois est une plante grimpante annuelle de la famille des Fabacées, cultivée pour ses graines comestibles riches en protéines et ses gousses tendres.',
        growingInfo:
            'Semez directement en pleine terre dès que le sol peut être travaillé au printemps. Tolère bien les températures fraîches. Préfère un sol bien drainé avec un pH neutre à légèrement alcalin. Installez un support pour les variétés grimpantes.',
        harvestInfo:
            'Pour les petits pois, récoltez lorsque les gousses sont bien remplies mais encore tendres. Pour les pois mange-tout, récoltez avant que les graines ne se développent complètement. Récoltez régulièrement pour stimuler la production.',
        nutritionalValue:
            'Excellente source de protéines végétales, fibres, vitamines A, C, K, et diverses vitamines du groupe B. Contient également du fer, magnésium et zinc.',
        commonProblems:
            'Peut être affecté par l\'oïdium, la pourriture grise et divers insectes comme les pucerons et les sitones. Sensible à la fonte des semis en conditions humides.',
        tips:
            'Évitez de cultiver des pois au même endroit pendant plusieurs années consécutives pour prévenir les maladies. L\'inoculation des semences avec des bactéries fixatrices d\'azote peut améliorer la croissance et le rendement.',
      ),
      CatalogItem(
        id: 'legume_10',
        name: 'Poivron',
        imagePath: 'assets/images/légumes/poivron.jpg',
        category: 'Légumes',
        scientificName: 'Capsicum annuum',
        origin: 'Amérique centrale et du Sud',
        description:
            'Le poivron est un légume-fruit de la famille des Solanacées, cultivé pour ses fruits creux aux couleurs variées (vert, rouge, jaune, orange) et à la saveur douce.',
        growingInfo:
            'Semez à l\'intérieur 8-10 semaines avant le dernier gel. Transplantez en pleine terre lorsque les températures nocturnes dépassent 10°C. Préfère un sol riche, bien drainé et un plein soleil.',
        harvestInfo:
            'Les poivrons peuvent être récoltés verts (immatures) ou complètement mûrs lorsqu\'ils ont atteint leur couleur finale (rouge, jaune, etc.). Coupez les fruits avec des ciseaux ou un couteau pour éviter d\'endommager la plante.',
        nutritionalValue:
            'Très riche en vitamine C (surtout les poivrons rouges mûrs), vitamine A, vitamine B6 et acide folique. Contient également des antioxydants comme les caroténoïdes et la quercétine.',
        commonProblems:
            'Peut être affecté par l\'anthracnose, le mildiou, les pucerons et les tétranyques. La pourriture apicale est courante en cas de manque de calcium ou d\'arrosage irrégulier.',
        tips:
            'Un paillage aide à maintenir l\'humidité du sol et à réduire les mauvaises herbes. Un support peut être nécessaire pour les plantes chargées de fruits. Évitez l\'excès d\'azote qui favorise la végétation au détriment de la fructification.',
      ),
      CatalogItem(
        id: 'legume_11',
        name: 'Pomme de Terre',
        imagePath: 'assets/images/légumes/pomme de terre.jpg',
        category: 'Légumes',
        scientificName: 'Solanum tuberosum',
        origin: 'Amérique du Sud (Andes)',
        description:
            'La pomme de terre est une plante tubéreuse de la famille des Solanacées, cultivée pour ses tubercules féculents qui constituent un aliment de base dans de nombreuses régions du monde.',
        growingInfo:
            'Plantez des tubercules entiers ou coupés (avec au moins un œil par morceau) au début du printemps dans un sol meuble, bien drainé et légèrement acide. Buttez les plants lorsqu\'ils atteignent 15-20 cm pour favoriser la formation des tubercules.',
        harvestInfo:
            'Récoltez les pommes de terre nouvelles dès qu\'elles atteignent une taille utilisable. Pour la conservation, attendez que le feuillage jaunisse et sèche. Laissez sécher les tubercules quelques heures avant de les stocker dans un endroit frais, sombre et sec.',
        nutritionalValue:
            'Bonne source de vitamines C et B6, potassium, manganèse et fibres (surtout dans la peau). Contient des antioxydants, notamment des flavonoïdes et des caroténoïdes.',
        commonProblems:
            'Peut être affectée par le mildiou, la gale commune, les doryphores et divers virus. Sensible à la pourriture des tubercules en conditions humides.',
        tips:
            'Pratiquez la rotation des cultures pour éviter les maladies. Ne plantez pas de pommes de terre là où d\'autres Solanacées (tomates, aubergines) ont poussé récemment. Stockez les pommes de terre à l\'abri de la lumière pour éviter le verdissement toxique.',
      ),
      CatalogItem(
        id: 'legume_12',
        name: 'Tomate',
        imagePath: 'assets/images/légumes/tomate.jpg',
        category: 'Légumes',
        scientificName: 'Solanum lycopersicum',
        origin: 'Amérique du Sud (Pérou, Équateur)',
        description:
            'La tomate est une plante potagère de la famille des Solanacées, cultivée pour ses fruits charnus et juteux utilisés comme légumes dans de nombreuses cuisines.',
        growingInfo:
            'Semez à l\'intérieur 6-8 semaines avant le dernier gel. Transplantez après tout risque de gel dans un sol riche et bien drainé. Nécessite un plein soleil et un support (tuteur ou cage) pour la plupart des variétés.',
        harvestInfo:
            'Récoltez lorsque les fruits sont complètement colorés mais encore fermes. La saveur est meilleure si les tomates mûrissent sur la plante. Coupez ou tordez doucement les fruits pour les détacher.',
        nutritionalValue:
            'Riche en lycopène (antioxydant), vitamines C, K, potassium et folate. La biodisponibilité du lycopène augmente avec la cuisson.',
        commonProblems:
            'Peut être affectée par le mildiou, l\'alternariose, les nématodes et divers insectes. La pourriture apicale est courante en cas de manque de calcium ou d\'arrosage irrégulier.',
        tips:
            'Supprimez les gourmands (pousses latérales) pour les variétés indéterminées afin de favoriser la production et l\'aération. Un arrosage régulier et un paillage aident à prévenir la fissuration des fruits et les maladies.',
      ),
    ];

    final fruits = [
      CatalogItem(
        id: 'fruit_1',
        name: 'Ananas',
        imagePath: 'assets/images/fruits/ananas.jpg',
        category: 'Fruits',
        scientificName: 'Ananas comosus',
        origin: 'Amérique du Sud (Brésil, Paraguay)',
        description:
            'L\'ananas est une plante tropicale de la famille des Broméliacées, cultivée pour son fruit composé sucré et acidulé surmonté d\'une couronne de feuilles.',
        growingInfo:
            'En régions tropicales, plantez la couronne d\'un ananas dans un sol sablonneux bien drainé et en plein soleil. En intérieur, placez la couronne dans un pot avec un sol bien drainé et exposez-la à une lumière vive et à des températures chaudes.',
        harvestInfo:
            'L\'ananas est prêt à être récolté lorsque sa peau passe du vert au jaune doré à la base et qu\'il dégage un parfum sucré. Coupez le fruit avec un couteau tranchant, en laissant quelques centimètres de tige.',
        nutritionalValue:
            'Riche en vitamine C, manganèse et bromélaïne (enzyme aux propriétés anti-inflammatoires). Contient également des fibres et des antioxydants.',
        commonProblems:
            'Peut être affecté par la pourriture des racines, les cochenilles et les nématodes. Sensible au gel et au froid.',
        tips:
            'L\'ananas ne continue pas à mûrir après la récolte, alors assurez-vous qu\'il soit bien mûr avant de le cueillir. En culture d\'intérieur, il peut prendre 2-3 ans avant de produire un fruit.',
      ),
      CatalogItem(
        id: 'fruit_2',
        name: 'Avocat',
        imagePath: 'assets/images/fruits/avocat.jpg',
        category: 'Fruits',
        scientificName: 'Persea americana',
        origin: 'Amérique centrale (Mexique, Guatemala)',
        description:
            'L\'avocat est le fruit de l\'avocatier, un arbre de la famille des Lauracées. Il se distingue par sa chair crémeuse et sa haute teneur en graisses saines.',
        growingInfo:
            'Dans les climats appropriés, plantez un arbre greffé dans un sol profond et bien drainé, en plein soleil ou mi-ombre. En pot, utilisez une graine (noyau) placée pointe vers le haut, partiellement immergée dans l\'eau ou plantée dans un terreau bien drainé.',
        harvestInfo:
            'Les avocats ne mûrissent pas sur l\'arbre. Récoltez-les lorsqu\'ils atteignent leur taille mature et laissez-les mûrir à température ambiante. Ils sont prêts lorsqu\'ils cèdent légèrement à la pression.',
        nutritionalValue:
            'Riche en graisses monoinsaturées bénéfiques pour le cœur, en fibres, vitamines K, E, C et potassium. Excellente source d\'acide folique.',
        commonProblems:
            'Peut être affecté par la pourriture des racines (Phytophthora), l\'anthracnose et divers insectes ravageurs. Sensible au gel et à l\'engorgement du sol.',
        tips:
            'Pour accélérer le mûrissement, placez l\'avocat dans un sac en papier avec une banane ou une pomme. Les avocatiers peuvent prendre 5-13 ans pour produire des fruits à partir d\'un noyau.',
      ),
      CatalogItem(
        id: 'fruit_3',
        name: 'Banane',
        imagePath: 'assets/images/fruits/banane.jpg',
        category: 'Fruits',
        scientificName: 'Musa spp.',
        origin: 'Asie du Sud-Est',
        description:
            'La banane est le fruit du bananier, une grande plante herbacée de la famille des Musacées. Les bananes douces sont consommées comme fruits, tandis que les bananes plantains sont utilisées comme légumes dans la cuisine.',
        growingInfo:
            'Cultivez dans des climats tropicaux ou subtropicaux, ou en serre dans les régions plus fraîches. Préfère un sol riche, humide mais bien drainé et une protection contre les vents forts. Multipliez par division des rejets.',
        harvestInfo:
            'Récoltez le régime entier lorsque les fruits sont bien développés mais encore verts. Suspendez-le dans un endroit frais et ombragé pour permettre aux bananes de mûrir progressivement.',
        nutritionalValue:
            'Excellente source de potassium, vitamines B6 et C, magnésium et fibres. L\'amidon résistant des bananes moins mûres favorise la santé intestinale.',
        commonProblems:
            'Peut être affecté par la maladie de Panama (fusariose), la sigatoka (maladie des taches noires) et divers insectes. Sensible au gel et aux vents forts.',
        tips:
            'Les bananiers ont besoin de beaucoup d\'eau et de nutriments. Un paillage épais aide à conserver l\'humidité et à fournir des nutriments. Après la fructification, coupez la tige qui a produit car elle ne donnera plus de fruits.',
      ),
      CatalogItem(
        id: 'fruit_4',
        name: 'Cerise',
        imagePath: 'assets/images/fruits/cerise.jpg',
        category: 'Fruits',
        scientificName:
            'Prunus avium (cerises douces), Prunus cerasus (cerises acides)',
        origin: 'Asie Mineure et Europe',
        description:
            'La cerise est le fruit du cerisier, un arbre fruitier de la famille des Rosacées. On distingue principalement les cerises douces (bigarreaux, guignes) et les cerises acides (griottes, amarelles).',
        growingInfo:
            'Plantez les cerisiers dans un sol bien drainé et ensoleillé. La plupart des variétés nécessitent un pollinisateur compatible. Protégez du gel tardif qui peut endommager les fleurs au printemps.',
        harvestInfo:
            'Récoltez lorsque les fruits sont complètement colorés et fermes, en coupant la tige avec les cerises pour éviter d\'endommager le fruit et prolonger sa conservation.',
        nutritionalValue:
            'Riche en anthocyanes et autres antioxydants. Bonne source de vitamines C, A, potassium et fibres. Les cerises contiennent de la mélatonine naturelle qui peut favoriser le sommeil.',
        commonProblems:
            'Peut être affecté par la moniliose, le chancre bactérien et divers insectes comme la mouche de la cerise et les pucerons. Les oiseaux sont souvent attirés par les fruits.',
        tips:
            'Utilisez des filets pour protéger les fruits des oiseaux. La taille doit être minimale et réalisée en été pour réduire les risques de maladies fongiques et bactériennes.',
      ),
      CatalogItem(
        id: 'fruit_5',
        name: 'Figue',
        imagePath: 'assets/images/fruits/figue.jpg',
        category: 'Fruits',
        scientificName: 'Ficus carica',
        origin: 'Moyen-Orient et Méditerranée occidentale',
        description:
            'La figue est le fruit du figuier, un arbre de la famille des Moracées. Ce fruit unique est en réalité une inflorescence inversée appelée syconium, contenant de nombreuses petites fleurs à l\'intérieur.',
        growingInfo:
            'Plantez dans un sol bien drainé et en plein soleil. Dans les régions froides, placez près d\'un mur orienté au sud pour bénéficier de la chaleur réfléchie. Certaines variétés sont auto-fertiles, d\'autres nécessitent une pollinisation par des guêpes spécifiques.',
        harvestInfo:
            'Récoltez les figues lorsqu\'elles sont complètement molles au toucher et que la peau commence à se fendiller. La présence d\'une goutte de nectar à l\'extrémité indique souvent la maturité parfaite.',
        nutritionalValue:
            'Excellente source de fibres, vitamines B6, K, potassium et magnésium. Contient des enzymes protéolytiques bénéfiques pour la digestion et des antioxydants.',
        commonProblems:
            'Peut être affecté par la rouille, diverses pourritures fongiques et des insectes comme les cochenilles. Sensible au gel sévère.',
        tips:
            'La taille doit être limitée car les figues se forment sur le bois de l\'année précédente. Un stress hydrique modéré peut améliorer la saveur des fruits, mais un arrosage régulier est nécessaire pendant la formation des fruits.',
      ),
      CatalogItem(
        id: 'fruit_6',
        name: 'Framboise',
        imagePath: 'assets/images/fruits/framboise.jpg',
        category: 'Fruits',
        scientificName: 'Rubus idaeus',
        origin: 'Europe et Asie occidentale',
        description:
            'La framboise est le fruit du framboisier, un arbuste épineux de la famille des Rosacées. C\'est un fruit composé formé de nombreuses petites drupes réunies autour d\'un réceptacle conique.',
        growingInfo:
            'Plantez dans un sol riche, légèrement acide et bien drainé. Préfère le plein soleil mais tolère une mi-ombre légère. Installez un support pour maintenir les cannes dressées et faciliter la récolte et l\'aération.',
        harvestInfo:
            'Récoltez lorsque les fruits se détachent facilement de la plante. Les framboises ne continuent pas à mûrir après la récolte, alors cueillez-les à pleine maturité pour une saveur optimale.',
        nutritionalValue:
            'Riche en fibres, vitamine C, manganèse et antioxydants comme les anthocyanes et l\'acide ellagique. Contient également des composés qui peuvent avoir des propriétés anti-inflammatoires.',
        commonProblems:
            'Peut être affecté par diverses maladies fongiques comme l\'anthracnose et la pourriture grise. Les insectes ravageurs incluent le ver des framboises et les punaises.',
        tips:
            'Taillez les vieilles cannes après la fructification pour favoriser une nouvelle croissance. Pour les variétés remontantes, une seconde taille en fin d\'hiver permet d\'obtenir une récolte plus abondante en été.',
      ),
      CatalogItem(
        id: 'fruit_7',
        name: 'Grenade',
        imagePath: 'assets/images/fruits/grenade.jpg',
        category: 'Fruits',
        scientificName: 'Punica granatum',
        origin: 'Iran et région méditerranéenne',
        description:
            'La grenade est le fruit du grenadier, un petit arbre ou arbuste de la famille des Lythracées. Elle est reconnaissable à son écorce coriace renfermant de nombreuses graines entourées d\'une pulpe juteuse et acidulée.',
        growingInfo:
            'Plantez dans un sol bien drainé et en plein soleil. Tolère la sécheresse une fois établi mais préfère des arrosages réguliers pendant la formation des fruits. Adapté aux climats méditerranéens avec des étés chauds et secs.',
        harvestInfo:
            'Récoltez lorsque le fruit a une couleur vive, qu\'il émet un son métallique lorsqu\'on le tape, et que l\'écorce devient dure. Coupez la tige près du fruit avec des sécateurs propres.',
        nutritionalValue:
            'Riche en polyphénols, tanins et anthocyanes aux propriétés antioxydantes puissantes. Bonne source de vitamines C, K, acide folique et potassium.',
        commonProblems:
            'Peut être affecté par la pourriture des fruits, divers champignons et insectes comme les pucerons et les cochenilles. La fissuration des fruits survient souvent lors d\'arrosages irréguliers.',
        tips:
            'Une légère taille en hiver aide à maintenir la forme et encourager la fructification. La production de fruits peut prendre 2-3 ans après la plantation. Dans les régions froides, cultivez en pot pour pouvoir rentrer l\'arbre en hiver.',
      ),
      CatalogItem(
        id: 'fruit_8',
        name: 'Kiwi Vine',
        imagePath: 'assets/images/fruits/Kiwi Vine.jpg',
        category: 'Fruits',
        scientificName: 'Actinidia deliciosa',
        origin: 'Chine',
        description:
            'Le kiwi est le fruit d\'une liane grimpante de la famille des Actinidiacées. Il est reconnaissable à sa peau brune duveteuse et sa chair verte émeraude parsemée de petites graines noires.',
        growingInfo:
            'Plantez dans un sol fertile, légèrement acide et bien drainé. Nécessite un support solide comme une treille ou une pergola. La plupart des variétés sont dioïques, nécessitant des plants mâles et femelles pour la pollinisation.',
        harvestInfo:
            'Récoltez lorsque les fruits sont fermes mais cèdent légèrement à la pression. En général, les kiwis sont récoltés avant complète maturité et continuent à mûrir à température ambiante.',
        nutritionalValue:
            'Exceptionnellement riche en vitamine C (plus que l\'orange), bonne source de vitamines K, E, acide folique, potassium et fibres. Contient également des enzymes protéolytiques comme l\'actinidine.',
        commonProblems:
            'Peut être affecté par le botrytis, diverses pourritures des racines et des insectes comme les cochenilles. Sensible aux gelées tardives qui peuvent endommager les nouvelles pousses.',
        tips:
            'Une taille régulière est nécessaire pour contrôler la croissance vigoureuse et favoriser la fructification. Les fruits se forment sur les pousses de l\'année courante issues du bois de l\'année précédente.',
      ),
      CatalogItem(
        id: 'fruit_9',
        name: 'Mangue',
        imagePath: 'assets/images/fruits/manga.jpg',
        category: 'Fruits',
        scientificName: 'Mangifera indica',
        origin: 'Inde et Asie du Sud-Est',
        description:
            'La mangue est le fruit du manguier, un arbre tropical de la famille des Anacardiacées. C\'est une drupe charnue à la peau lisse, dont la couleur varie du vert au jaune-orange ou rouge selon les variétés.',
        growingInfo:
            'Dans les climats tropicaux, plantez en plein soleil dans un sol bien drainé. Protégez des vents forts. En pot ou dans les régions plus fraîches, utilisez des variétés naines et protégez du froid.',
        harvestInfo:
            'Récoltez lorsque la couleur de la peau change et que le fruit commence à dégager un parfum sucré. La mangue continue à mûrir après la récolte, alors cueillez-la légèrement ferme si vous ne prévoyez pas de la consommer immédiatement.',
        nutritionalValue:
            'Excellente source de vitamines A et C, ainsi que de folate et de vitamine B6. Contient des antioxydants comme la quercétine, le bêta-carotène et des composés phénoliques.',
        commonProblems:
            'Peut être affecté par l\'anthracnose, l\'oïdium et divers insectes comme les mouches des fruits et les cochenilles. Sensible au gel et à l\'engorgement du sol.',
        tips:
            'Les manguiers peuvent prendre 5-8 ans pour commencer à produire des fruits à partir de graines. La greffe permet d\'obtenir des arbres qui fructifient plus rapidement. Un stress hydrique modéré avant la floraison peut favoriser une meilleure fructification.',
      ),
      CatalogItem(
        id: 'fruit_10',
        name: 'Noix de Coco',
        imagePath: 'assets/images/fruits/noit de coco.jpg',
        category: 'Fruits',
        scientificName: 'Cocos nucifera',
        origin: 'Régions tropicales d\'Asie du Sud-Est et îles du Pacifique',
        description:
            'La noix de coco est le fruit du cocotier, un palmier de la famille des Arécacées. Elle est composée d\'une coque fibreuse extérieure, d\'une coque dure et d\'un endosperme blanc (la chair) entourant une cavité remplie d\'eau de coco.',
        growingInfo:
            'Nécessite un climat tropical chaud et humide. Plantez directement une noix de coco entière ou germée dans un sol sablonneux bien drainé, en plein soleil et à l\'abri des vents forts. En intérieur, possible uniquement dans de grandes serres tropicales.',
        harvestInfo:
            'Les noix de coco vertes (jeunes) sont récoltées pour leur eau sucrée, tandis que les noix brunes (matures) sont récoltées pour leur chair. Grimpez à l\'arbre ou utilisez un long bâton avec un crochet pour détacher les fruits.',
        nutritionalValue:
            'La chair est riche en graisses saturées saines (acide laurique), fibres et minéraux comme le manganèse, le cuivre et le fer. L\'eau de coco contient des électrolytes naturels comme le potassium et le magnésium.',
        commonProblems:
            'Peut être affecté par diverses maladies fongiques et bactériennes comme la pourriture du bourgeon terminal. Les insectes ravageurs incluent le rhinocéros du cocotier et divers acariens.',
        tips:
            'Les cocotiers peuvent mettre 6-10 ans avant de commencer à produire des fruits. Ils ont besoin d\'un arrosage régulier pendant l\'établissement mais deviennent plus tolérants à la sécheresse une fois matures.',
      ),
      CatalogItem(
        id: 'fruit_11',
        name: 'Orange',
        imagePath: 'assets/images/fruits/orange.jpg',
        category: 'Fruits',
        scientificName: 'Citrus sinensis',
        origin: 'Chine et Asie du Sud-Est',
        description:
            'L\'orange est le fruit de l\'oranger, un arbre de la famille des Rutacées. C\'est un agrume à la peau épaisse de couleur orange et à la pulpe juteuse divisée en quartiers.',
        growingInfo:
            'Plantez dans un sol bien drainé et légèrement acide. Nécessite beaucoup de soleil et une protection contre le gel. Dans les régions froides, cultivez en pot pour pouvoir rentrer l\'arbre en hiver.',
        harvestInfo:
            'Récoltez lorsque les fruits ont atteint leur couleur caractéristique et qu\'ils se détachent facilement de la branche. Les oranges ne continuent pas à mûrir après la cueillette, alors attendez qu\'elles soient complètement mûres.',
        nutritionalValue:
            'Excellente source de vitamine C, folate, thiamine et potassium. Contient des flavonoïdes comme l\'hespéridine et la naringénine aux propriétés antioxydantes.',
        commonProblems:
            'Peut être affecté par diverses maladies fongiques comme le chancre des agrumes et des insectes comme les pucerons, les cochenilles et les mouches des fruits.',
        tips:
            'Un arrosage régulier est essentiel, surtout pendant la formation des fruits, mais évitez l\'excès d\'eau qui peut favoriser les maladies des racines. Une taille légère après la récolte aide à maintenir une forme compacte et à améliorer la circulation d\'air.',
      ),
      CatalogItem(
        id: 'fruit_12',
        name: 'Pastèque',
        imagePath: 'assets/images/fruits/pastéque.jpg',
        category: 'Fruits',
        scientificName: 'Citrullus lanatus',
        origin: 'Afrique',
        description:
            'La pastèque est une plante grimpante ou rampante de la famille des Cucurbitacées, cultivée pour son fruit volumineux à la chair juteuse, sucrée et rafraîchissante, généralement rouge ou rose avec des graines noires.',
        growingInfo:
            'Semez directement après tout risque de gel dans un sol riche, bien drainé et en plein soleil. Nécessite beaucoup d\'espace (1-2 m² par plante) et des températures chaudes pour bien se développer.',
        harvestInfo:
            'La pastèque est prête lorsque la partie en contact avec le sol passe du blanc au jaune crème, que la vrille la plus proche du fruit est sèche, et que le fruit émet un son sourd lorsqu\'on le tape.',
        nutritionalValue:
            'Composée à 92% d\'eau, la pastèque est faible en calories mais riche en lycopène (antioxydant), vitamines A, C et divers minéraux comme le potassium et le magnésium.',
        commonProblems:
            'Peut être affectée par l\'oïdium, l\'anthracnose et divers insectes comme les pucerons et les coléoptères du concombre. Sensible à diverses pourritures des fruits par temps humide.',
        tips:
            'Utilisez un paillis noir pour réchauffer le sol et réduire les mauvaises herbes. Limitez l\'arrosage à l\'approche de la maturité pour concentrer la saveur. Placez une planche ou une tuile sous chaque fruit pour éviter le contact direct avec le sol humide.',
      ),
      CatalogItem(
        id: 'fruit_13',
        name: 'Pêche',
        imagePath: 'assets/images/fruits/pêche.jpg',
        category: 'Fruits',
        scientificName: 'Prunus persica',
        origin: 'Chine',
        description:
            'La pêche est le fruit du pêcher, un arbre de la famille des Rosacées. C\'est une drupe charnue à la peau duveteuse (ou lisse pour les nectarines) et à la chair juteuse, sucrée et parfumée.',
        growingInfo:
            'Plantez dans un sol profond, bien drainé et légèrement calcaire. Nécessite une exposition ensoleillée et une protection contre les vents forts. La plupart des variétés sont auto-fertiles.',
        harvestInfo:
            'Récoltez lorsque la couleur de fond de la peau (non exposée au soleil) passe du vert au jaune ou blanc-crème et que le fruit cède légèrement à la pression. Manipulez avec soin car les pêches mûres sont fragiles.',
        nutritionalValue:
            'Bonne source de vitamines A, C, E, potassium et fibres. Contient des antioxydants comme les caroténoïdes et les acides phénoliques.',
        commonProblems:
            'Peut être affecté par la cloque du pêcher, l\'oïdium, la moniliose et divers insectes comme la mouche des fruits et les pucerons. Sensible aux gelées tardives qui peuvent détruire les fleurs.',
        tips:
            'Taillez en fin d\'hiver pour favoriser une croissance équilibrée et stimuler la production de nouvelles branches fruitières. Éclaircissez les jeunes fruits pour obtenir des pêches plus grosses et prévenir la casse des branches.',
      ),
      CatalogItem(
        id: 'fruit_14',
        name: 'Poire',
        imagePath: 'assets/images/fruits/poire.jpg',
        category: 'Fruits',
        scientificName: 'Pyrus communis',
        origin: 'Europe centrale et orientale, Asie occidentale',
        description:
            'La poire est le fruit du poirier, un arbre de la famille des Rosacées. Elle se distingue par sa forme caractéristique, sa chair sucrée et fondante, et sa texture légèrement granuleuse.',
        growingInfo:
            'Plantez dans un sol profond et bien drainé, légèrement calcaire. Préfère une exposition ensoleillée mais tolère une légère ombre. La plupart des variétés nécessitent un pollinisateur compatible.',
        harvestInfo:
            'Contrairement aux pommes, les poires doivent être récoltées avant pleine maturité et laissées mûrir à température ambiante. Testez en soulevant légèrement le fruit; s\'il se détache facilement, il est prêt à être cueilli.',
        nutritionalValue:
            'Bonne source de fibres solubles et insolubles, vitamines C, K, cuivre et potassium. Les fibres de pectine aident à réguler le système digestif et le cholestérol.',
        commonProblems:
            'Peut être affecté par le feu bactérien, la tavelure et divers insectes comme le carpocapse des pommes et des poires. Les oiseaux et guêpes sont attirés par les fruits mûrs.',
        tips:
            'La taille est essentielle pour maintenir la forme et stimuler la production de dards fruitiers. Les poiriers peuvent prendre 4-6 ans avant de commencer à produire des fruits significatifs.',
      ),
      CatalogItem(
        id: 'fruit_15',
        name: 'Pomme',
        imagePath: 'assets/images/fruits/pomme.jpg',
        category: 'Fruits',
        scientificName: 'Malus domestica',
        origin: 'Asie centrale (Kazakhstan)',
        description:
            'La pomme est le fruit du pommier, un arbre fruitier de la famille des Rosacées. C\'est l\'un des fruits les plus cultivés et consommés dans le monde, disponible en milliers de variétés aux couleurs, saveurs et textures diverses.',
        growingInfo:
            'Plantez dans un sol profond, fertile et bien drainé, légèrement acide à neutre. Préfère une exposition ensoleillée. La plupart des variétés nécessitent un pollinisateur compatible pour une bonne fructification.',
        harvestInfo:
            'Récoltez lorsque les pommes se détachent facilement en soulevant et tournant légèrement. La couleur de fond (non exposée au soleil) change généralement du vert au jaune ou blanc à maturité.',
        nutritionalValue:
            'Bonne source de fibres solubles (pectine), vitamine C et divers antioxydants comme la quercétine. La majorité des nutriments se trouvent dans ou juste sous la peau.',
        commonProblems:
            'Peut être affecté par la tavelure, l\'oïdium, le feu bactérien et divers insectes comme le carpocapse et les pucerons. Les mammifères comme les cerfs et les rongeurs peuvent endommager l\'écorce.',
        tips:
            'La taille d\'hiver aide à maintenir la forme et à encourager la production de nouvelles branches fruitières. Éclaircissez les jeunes fruits pour obtenir des pommes plus grosses et prévenir la production alternée (forte récolte une année, faible la suivante).',
      ),
      CatalogItem(
        id: 'fruit_16',
        name: 'Prune',
        imagePath: 'assets/images/fruits/prune.jpg',
        category: 'Fruits',
        scientificName: 'Prunus domestica',
        origin: 'Europe et Asie occidentale',
        description:
            'La prune est le fruit du prunier, un arbre de la famille des Rosacées. C\'est une drupe charnue aux couleurs variées (bleu, violet, rouge, jaune), à la chair juteuse et souvent sucrée.',
        growingInfo:
            'Plantez dans un sol bien drainé, profond et modérément fertile. Préfère une exposition ensoleillée mais tolère une légère ombre. Certaines variétés sont auto-fertiles, d\'autres nécessitent un pollinisateur compatible.',
        harvestInfo:
            'Récoltez lorsque les fruits sont colorés, légèrement mous au toucher et se détachent facilement de la branche. Les prunes destinées à la consommation immédiate peuvent être laissées plus longtemps sur l\'arbre pour développer leur saveur.',
        nutritionalValue:
            'Bonne source de vitamines C, K, potassium et fibres. Contient des antoxydants comme les anthocyanes et l\'acide néochlorogénique. Les prunes séchées (pruneaux) sont particulièrement riches en fibres et en antioxydants.',
        commonProblems:
            'Peut être affecté par la moniliose, la maladie des pochettes (cloque), la sharka (virus) et divers insectes comme le carpocapse et les pucerons.',
        tips:
            'Une taille régulière aide à maintenir une production fruitière constante et à favoriser la circulation d\'air pour réduire les maladies fongiques. Les pruniers sont généralement plus tolérants aux conditions difficiles que d\'autres arbres fruitiers.',
      ),
      CatalogItem(
        id: 'fruit_17',
        name: 'Raisin Blanc',
        imagePath: 'assets/images/fruits/Raisin blanc.jpg',
        category: 'Fruits',
        scientificName: 'Vitis vinifera',
        origin: 'Moyen-Orient et Europe',
        description:
            'Le raisin est le fruit de la vigne, une plante grimpante de la famille des Vitacées. Les raisins blancs (qui sont en réalité verts ou jaunes) se développent en grappes et sont appréciés frais ou transformés en vin, jus ou raisins secs.',
        growingInfo:
            'Plantez dans un sol profond, bien drainé et moyennement fertile. Nécessite une exposition ensoleillée et un support solide comme un treillis ou une pergola. Taillez régulièrement pour contrôler la croissance et favoriser la fructification.',
        harvestInfo:
            'Récoltez lorsque les raisins ont atteint leur couleur finale, sont tendres au toucher et ont développé leur saveur sucrée caractéristique. Coupez la grappe entière avec des sécateurs.',
        nutritionalValue:
            'Source de vitamines C, K, thiamine, riboflavine et potassium. Contient des antioxydants comme le resvératrol et la quercétine, principalement dans la peau.',
        commonProblems:
            'Peut être affecté par le mildiou, l\'oïdium, la pourriture grise et divers insectes comme les phylloxéras et les guêpes. Les oiseaux sont souvent attirés par les fruits mûrs.',
        tips:
            'La taille est cruciale pour la production de raisin; familiarisez-vous avec les techniques spécifiques pour votre système de conduite. Utilisez des filets pour protéger les grappes des oiseaux. L\'éclaircissage des grappes peut améliorer la qualité des fruits.',
      ),
      CatalogItem(
        id: 'fruit_18',
        name: 'Fraise',
        imagePath: 'assets/images/fruits/fraise.jpg',
        category: 'Fruits',
        scientificName: 'Fragaria × ananassa',
        origin: 'Hybride créé en Europe au 18ème siècle',
        description:
            'La fraise est le fruit du fraisier, une plante herbacée de la famille des Rosacées. Ce que nous considérons comme le fruit est en réalité un réceptacle charnu portant de nombreux petits akènes à sa surface (les graines apparentes).',
        growingInfo:
            'Plantez dans un sol riche, légèrement acide et bien drainé. Préfère le plein soleil mais tolère une mi-ombre légère. Espacez les plants pour permettre une bonne circulation d\'air. Renouvelez les plantations tous les 3-4 ans.',
        harvestInfo:
            'Récoltez lorsque les fruits sont complètement rouges (ou de la couleur caractéristique de la variété) et fermes. Coupez ou pincez la tige plutôt que de tirer sur le fruit pour éviter d\'endommager la plante.',
        nutritionalValue:
            'Excellente source de vitamine C (plus que l\'orange à poids égal), manganèse et acide folique. Contient divers antioxydants comme les anthocyanes, les acides ellagiques et les flavonoïdes.',
        commonProblems:
            'Peut être affectée par l\'oïdium, diverses pourritures des fruits, et des insectes comme les limaces, les pucerons et les tétranyques. Les oiseaux sont souvent attirés par les fruits.',
        tips:
            'Utilisez du paillis pour garder les fruits propres et prévenir les maladies. Retirez les stolons (sauf ceux destinés à créer de nouveaux plants) pour concentrer l\'énergie sur la production de fruits. Pour une culture en pot, choisissez des variétés remontantes pour une production prolongée.',
      ),
    ];

    switch (category) {
      case 'Légumes':
        return vegetables;
      case 'Fruits':
        return fruits;
      case 'Tous les articles':
      default:
        return [...vegetables, ...fruits];
    }
  }
}

class ItemCard extends StatelessWidget {
  final CatalogItem item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green.shade300,
                      child: Center(
                        child: Icon(
                          item.category == 'Fruits'
                              ? Icons.apple
                              : item.category == 'Légumes'
                                  ? Icons.eco
                                  : Icons.spa,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetailPage extends StatefulWidget {
  final CatalogItem item;

  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .collection('saved_items')
            .doc(widget.item.id)
            .get();
        setState(() {
          _isSaved = doc.exists;
        });
      } catch (e) {
        print('Error checking saved status: $e');
      }
    }
  }

  
  Future<void> _toggleSaveItem() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez vous connecter pour sauvegarder.')),
      );
      return;
    }

    try {
      final savedItemsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('saved_items')
          .doc(widget.item.id);

      if (_isSaved) {
        await savedItemsRef.delete();
        setState(() {
          _isSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article retiré des favoris.')),
        );
      } else {
        await savedItemsRef.set({
          'id': widget.item.id,
          'name': widget.item.name,
          'imagePath': widget.item.imagePath,
          'category': widget.item.category,
          'scientificName': widget.item.scientificName,
          'origin': widget.item.origin,
          'description': widget.item.description,
          'growingInfo': widget.item.growingInfo,
          'harvestInfo': widget.item.harvestInfo,
          'nutritionalValue': widget.item.nutritionalValue,
          'commonProblems': widget.item.commonProblems,
          'tips': widget.item.tips,
        });
        setState(() {
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article sauvegardé !')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.item.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green.shade300,
                        child: Center(
                          child: Icon(
                            widget.item.category == 'Fruits'
                                ? Icons.apple
                                : widget.item.category == 'Légumes'
                                    ? Icons.eco
                                    : Icons.spa,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF0C3C26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                      'Catégorie', widget.item.category, Icons.category),
                  _buildInfoCard(
                    'Nom scientifique',
                    widget.item.scientificName,
                    Icons.science,
                  ),
                  _buildInfoCard('Origine', widget.item.origin, Icons.public),
                  _buildDetailSection('Description', widget.item.description),
                  _buildDetailSection(
                    'Informations de culture',
                    widget.item.growingInfo,
                  ),
                  _buildDetailSection('Récolte', widget.item.harvestInfo),
                  _buildDetailSection(
                    'Valeur nutritionnelle',
                    widget.item.nutritionalValue,
                  ),
                  _buildDetailSection(
                    'Problèmes courants',
                    widget.item.commonProblems,
                  ),
                  _buildDetailSection('Conseils et astuces', widget.item.tips),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0C3C26),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSaveItem,
        backgroundColor: Colors.green,
        child: Icon(
          _isSaved ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.withOpacity(0.2),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


class CatalogItem {
  final String id;
  final String name;
  final String imagePath;
  final String category;
  final String scientificName;
  final String origin;
  final String description;
  final String growingInfo;
  final String harvestInfo;
  final String nutritionalValue;
  final String commonProblems;
  final String tips;

  CatalogItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.scientificName,
    required this.origin,
    required this.description,
    required this.growingInfo,
    required this.harvestInfo,
    required this.nutritionalValue,
    required this.commonProblems,
    required this.tips,
  });
}
