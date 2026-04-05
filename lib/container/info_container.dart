import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoContainer extends StatefulWidget {
  const InfoContainer({
    super.key,
    required this.useGlassTheme,
    required this.onThemeModeChanged,
  });

  final bool useGlassTheme;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<InfoContainer> createState() => _InfoContainerState();
}

class _InfoContainerState extends State<InfoContainer> {
  String _version = '--';
  String _buildNumber = '--';

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }

    setState(() {
      _buildNumber = packageInfo.buildNumber;
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool wide = width >= 900;
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = widget.useGlassTheme ? Colors.white : colorScheme.onSurface;
    final subtitleColor = widget.useGlassTheme ? Colors.white70 : colorScheme.onSurfaceVariant;

    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w800,
        );

    final styleSwitcher = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.useGlassTheme ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.useGlassTheme
              ? Colors.white.withValues(alpha: 0.10)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Chế độ giao diện',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.auto_awesome_rounded),
                label: Text('Material 3'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.blur_on_rounded),
                label: Text('Glass UI'),
              ),
            ],
            selected: <bool>{widget.useGlassTheme},
            onSelectionChanged: (Set<bool> selection) {
              widget.onThemeModeChanged(selection.first);
            },
          ),
        ],
      ),
    );

    final content = wide
        ? Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        color: widget.useGlassTheme
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: widget.useGlassTheme ? Colors.white : const Color(0xFF2B6CF6),
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Lịch Vạn Niên', style: titleStyle),
                    const SizedBox(height: 8),
                    Text(
                      'Tùy chọn nhanh giữa bố cục Material 3 hiện đại và Glass UI trong suốt như hiện tại.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: subtitleColor,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    styleSwitcher,
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Version',
                      value: _version,
                      useGlassTheme: widget.useGlassTheme,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Build',
                      value: _buildNumber,
                      useGlassTheme: widget.useGlassTheme,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Platforms',
                      value: 'Android • iOS • Web • macOS',
                      useGlassTheme: widget.useGlassTheme,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: widget.useGlassTheme ? Colors.white.withValues(alpha: 0.10) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: widget.useGlassTheme ? Colors.white : const Color(0xFF2B6CF6),
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text('Lịch Vạn Niên', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Chuyển nhanh giữa Material 3 và Glass UI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 24),
              styleSwitcher,
              const SizedBox(height: 12),
              _InfoTile(label: 'Version', value: _version, useGlassTheme: widget.useGlassTheme),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Build',
                value: _buildNumber,
                useGlassTheme: widget.useGlassTheme,
              ),
            ],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        image: widget.useGlassTheme
            ? const DecorationImage(
                image: AssetImage('assets/image_blue_blur.jpg'),
                fit: BoxFit.cover,
              )
            : null,
        gradient: widget.useGlassTheme
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF7FAFE), Color(0xFFE9F0FA)],
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.useGlassTheme
                ? <Color>[
                    Colors.black.withValues(alpha: 0.30),
                    const Color(0xFF07111F).withValues(alpha: 0.88),
                  ]
                : <Color>[
                    Colors.white.withValues(alpha: 0.68),
                    const Color(0xFFEFF4FB).withValues(alpha: 0.94),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1100 : 640),
              child: Padding(
                padding: EdgeInsets.fromLTRB(wide ? 28 : 20, 24, wide ? 28 : 20, 90),
                child: Column(
                  children: <Widget>[
                    Expanded(child: Center(child: content)),
                    Text(
                      'Developed by ThienMD',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.useGlassTheme,
  });

  final String label;
  final String value;
  final bool useGlassTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: useGlassTheme ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: useGlassTheme ? Colors.white.withValues(alpha: 0.10) : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: useGlassTheme ? Colors.white70 : colorScheme.onSurfaceVariant,
                ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: useGlassTheme ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
