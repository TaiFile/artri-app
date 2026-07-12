import 'package:artriapp/utils/enums/index.dart';
import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EvolutionPage extends StatefulWidget {
  const EvolutionPage({super.key});

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
  // Métricas visíveis no gráfico. Começa mostrando a dor
  final Set<EvolutionMetric> _visible = {EvolutionMetric.pain};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvolutionViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EvolutionViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'SUA EVOLUÇÃO',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe seus sintomas dos últimos 7 dias',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildChips(),
            const SizedBox(height: 24),
            Expanded(child: _buildChartArea(viewModel)),
          ],
        );
      },
    );
  }

  Widget _buildChips() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: EvolutionMetric.values.map((metric) {
        final selected = _visible.contains(metric);
        return FilterChip(
          label: Text(metric.label),
          selected: selected,
          selectedColor: metric.color.withValues(alpha: 0.25),
          checkmarkColor: metric.color,
          onSelected: (value) => setState(() {
            if (value) {
              _visible.add(metric);
            } else {
              _visible.remove(metric);
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _buildChartArea(EvolutionViewModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
              ),
              onPressed: () => context.read<EvolutionViewModel>().load(),
              child: Text(
                'Tentar novamente',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasAnyData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Ainda não há registros no diário. Registre seus sintomas para '
            'acompanhar sua evolução aqui.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24.0, left: 8.0, bottom: 24.0),
      child: LineChart(_mainData(viewModel)),
    );
  }

  LineChartData _mainData(EvolutionViewModel viewModel) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: AppColors.neutral, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidgets(value, meta, viewModel),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (EvolutionViewModel.daysWindow - 1).toDouble(),
      minY: 0,
      maxY: 10,
      lineBarsData: [
        for (final metric in EvolutionMetric.values)
          if (_visible.contains(metric)) _barFor(metric, viewModel),
      ],
    );
  }

  LineChartBarData _barFor(EvolutionMetric metric, EvolutionViewModel viewModel) {
    final series = viewModel.seriesFor(metric);
    final spots = <FlSpot>[
      for (int i = 0; i < series.length; i++)
        if (series[i] != null) FlSpot(i.toDouble(), series[i]!),
    ];

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: metric.color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        // Só preenche a área quando uma única métrica está visível,
        // para não sobrepor cores com várias linhas
        show: _visible.length == 1,
        color: metric.color.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _bottomTitleWidgets(
    double value,
    TitleMeta meta,
    EvolutionViewModel viewModel,
  ) {
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      color: Colors.black54,
    );

    final idx = value.toInt();
    final label = (idx >= 0 && idx < viewModel.days.length)
        ? _weekdayAbbrev(viewModel.days[idx].weekday)
        : '';

    return SideTitleWidget(meta: meta, child: Text(label, style: style));
  }

  String _weekdayAbbrev(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.black54,
    );
    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.center,
    );
  }
}
