import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/design_bloc.dart';

class BagSelectionScreen extends StatefulWidget {
  const BagSelectionScreen({super.key});

  @override
  State<BagSelectionScreen> createState() => _BagSelectionScreenState();
}

class _BagSelectionScreenState extends State<BagSelectionScreen> {
  String? _selectedBagType;

  final List<Map<String, dynamic>> _bagTypes = [
    {
      'type': 'Quad Seal',
      'icon': Icons.shopping_bag_outlined,
      'description': 'Four-sided seal for maximum stability',
    },
    {
      'type': 'Gusset',
      'icon': Icons.shopping_bag,
      'description': 'Expandable sides for extra capacity',
    },
    {
      'type': 'Stand Up Pouch',
      'icon': Icons.inventory_2_outlined,
      'description': 'Self-standing design for retail display',
    },
    {
      'type': 'Flat Bottom',
      'icon': Icons.square_outlined,
      'description': 'Stable flat base for easy storage',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bag Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<DesignBloc, DesignState>(
        listener: (context, state) {
          if (state is BagTypeSelected) {
            context.push('/design-preview');
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _bagTypes.length,
                  itemBuilder: (context, index) {
                    final bag = _bagTypes[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: _BagTypeCard(
                        type: bag['type'],
                        icon: bag['icon'],
                        description: bag['description'],
                        isSelected: _selectedBagType == bag['type'],
                        onTap: () {
                          setState(() => _selectedBagType = bag['type']);
                        },
                      ),
                    );
                  },
                ),
              ),
              if (_selectedBagType != null)
                FadeInUp(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<DesignBloc>().add(
                                SelectBagTypeEvent(_selectedBagType!),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BagTypeCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _BagTypeCard({
    required this.type,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
