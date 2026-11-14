$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:wfi="clr-namespace:System.Windows.Forms.Integration;assembly=WindowsFormsIntegration"
        Title="WinFlexOS V3.0" Height="950" Width="1450"
        WindowStartupLocation="CenterScreen" 
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        FontFamily="{DynamicResource ThemeFont}" Name="MainWindow">
    
    <Window.Resources>
        <!-- COLORS -->
        <SolidColorBrush x:Key="ThemeBg" Color="#0F0F0F"/>
        <SolidColorBrush x:Key="ThemeSidebar" Color="#141414"/>
        <SolidColorBrush x:Key="ThemeCardBg" Color="#1E1E1E"/>
        <SolidColorBrush x:Key="ThemeFg" Color="#FFFFFF"/>          
        <SolidColorBrush x:Key="ThemeSubText" Color="#B0B0B0"/>     
        <SolidColorBrush x:Key="ThemeAccent" Color="#00BFFF"/>      
        <SolidColorBrush x:Key="ThemeBorder" Color="#2A2A2A"/>
        <SolidColorBrush x:Key="ThemeSidebarFg" Color="#B0B0B0"/>   
        <SolidColorBrush x:Key="ThemeWinCtrl" Color="#AAAAAA"/>     
        
        <!-- DYNAMIC STYLING RESOURCES -->
        <CornerRadius x:Key="ThemeCornerRadius">16</CornerRadius>
        <SolidColorBrush x:Key="ThemeTitleBg" Color="Transparent"/>
        <SolidColorBrush x:Key="ThemeTitleFg" Color="#00BFFF"/>
        <Thickness x:Key="ThemeBorderThickness">1</Thickness>
        <FontFamily x:Key="ThemeFont">Bahnschrift, Segoe UI, sans-serif</FontFamily>
        
        <!-- VISIBILITY TOGGLES -->
        <Visibility x:Key="VisModern">Visible</Visibility>
        <Visibility x:Key="VisRetro">Collapsed</Visibility>

        <DropShadowEffect x:Key="NeonGlow" BlurRadius="15" ShadowDepth="0" Color="{Binding Color, Source={StaticResource ThemeAccent}}" Opacity="0.4"/>
        <DropShadowEffect x:Key="CardShadow" BlurRadius="20" ShadowDepth="5" Direction="270" Color="Black" Opacity="0.2"/>

        <!-- CONTEXT MENU STYLE -->
        <Style TargetType="ContextMenu">
            <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ThemeBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="HasDropShadow" Value="True"/>
        </Style>

        <Style TargetType="MenuItem">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="MenuItem">
                        <Border x:Name="Bd" Padding="{TemplateBinding Padding}" Background="{TemplateBinding Background}" BorderThickness="0">
                            <ContentPresenter Content="{TemplateBinding Header}" HorizontalAlignment="Left" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsHighlighted" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource ThemeAccent}"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ANIMATION RESOURCES -->
        <Storyboard x:Key="FadeInUp">
            <DoubleAnimation Storyboard.TargetProperty="Opacity" From="0" To="1" Duration="0:0:0.25"/>
            <DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.Y)" From="20" To="0" Duration="0:0:0.25">
                <DoubleAnimation.EasingFunction><ExponentialEase EasingMode="EaseOut" Exponent="4"/></DoubleAnimation.EasingFunction>
            </DoubleAnimation>
        </Storyboard>

        <!-- MODERN SCROLLBAR STYLE (REPLACED) -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid x:Name="GridRoot" Width="8" Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="true" Focusable="false">
                                <Track.Thumb>
                                    <Thumb x:Name="Thumb">
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border x:Name="ThumbVisual" Background="#55888888" CornerRadius="4"/>
                                                <ControlTemplate.Triggers>
                                                    <Trigger Property="IsMouseOver" Value="True">
                                                        <Setter TargetName="ThumbVisual" Property="Background" Value="{DynamicResource ThemeAccent}"/>
                                                    </Trigger>
                                                    <Trigger Property="IsDragging" Value="True">
                                                        <Setter TargetName="ThumbVisual" Property="Background" Value="{DynamicResource ThemeFg}"/>
                                                    </Trigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="GridRoot" Property="Width" Value="12"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBoxItem">
            <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBoxItem">
                        <Border Name="Bd" Background="{TemplateBinding Background}" Padding="5">
                            <ContentPresenter />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource ThemeAccent}"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource ThemeBorder}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ComboBox">
             <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
             <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/>
             <Setter Property="BorderBrush" Value="{DynamicResource ThemeBorder}"/>
             <Setter Property="Height" Value="30"/>
             <Setter Property="FontSize" Value="14"/>
             <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton Name="ToggleButton" Grid.Column="2" Focusable="false" IsChecked="{Binding Path=IsDropDownOpen,Mode=TwoWay,RelativeSource={RelativeSource TemplatedParent}}" ClickMode="Press">
                                <ToggleButton.Template>
                                    <ControlTemplate TargetType="ToggleButton">
                                        <Border Background="{DynamicResource ThemeCardBg}" BorderBrush="{DynamicResource ThemeBorder}" BorderThickness="1" CornerRadius="6">
                                            <Grid>
                                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="20"/></Grid.ColumnDefinitions>
                                                <Path Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center" Fill="{DynamicResource ThemeSubText}" Data="M 0 0 L 4 4 L 8 0 Z"/>
                                            </Grid>
                                        </Border>
                                    </ControlTemplate>
                                </ToggleButton.Template>
                            </ToggleButton>
                            <ContentPresenter Name="ContentSite" IsHitTestVisible="False"  Content="{TemplateBinding SelectionBoxItem}" Margin="10,0,23,0" VerticalAlignment="Center" HorizontalAlignment="Left" />
                            <Popup Name="Popup" Placement="Bottom" IsOpen="{TemplateBinding IsDropDownOpen}" AllowsTransparency="True" Focusable="False" PopupAnimation="Slide">
                                <Grid Name="DropDown" SnapsToDevicePixels="True" MinWidth="{TemplateBinding ActualWidth}" MaxHeight="{TemplateBinding MaxDropDownHeight}">
                                    <Border x:Name="DropDownBorder" Background="{DynamicResource ThemeCardBg}" BorderThickness="1" BorderBrush="{DynamicResource ThemeBorder}" CornerRadius="6"/>
                                    <ScrollViewer Margin="4,6,4,6" SnapsToDevicePixels="True"><StackPanel IsItemsHost="True" /></ScrollViewer>
                                </Grid>
                            </Popup>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
             </Setter>
        </Style>
        
        <Style TargetType="CheckBox">
             <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
             <Setter Property="FontSize" Value="14"/>
             <Setter Property="Margin" Value="0,5"/>
             <Setter Property="Cursor" Value="Hand"/>
        </Style>
        
        <Style TargetType="RadioButton">
             <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
             <Setter Property="FontSize" Value="14"/>
             <Setter Property="Margin" Value="0,5"/>
             <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style x:Key="SidebarBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeSidebarFg}"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="FontSize" Value="14"/> 
            <Setter Property="FontWeight" Value="Normal"/>
            <Setter Property="Margin" Value="10,1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Effect" Value="{DynamicResource NeonGlow}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Bd" Background="{TemplateBinding Background}" CornerRadius="8" RenderTransformOrigin="0.5,0.5">
                            <Border.RenderTransform>
                                <ScaleTransform x:Name="SidebarScale" ScaleX="1" ScaleY="1"/>
                            </Border.RenderTransform>
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="4"/><ColumnDefinition Width="40"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <Border Name="Indicator" Grid.Column="0" Width="3" Height="25" Background="Transparent" CornerRadius="1.5"/>
                                <TextBlock Name="btnIcon" Text="{TemplateBinding Tag}" Grid.Column="1" FontFamily="Segoe MDL2 Assets" FontSize="18" VerticalAlignment="Center" HorizontalAlignment="Center" Foreground="{TemplateBinding Foreground}"/>
                                <ContentPresenter Grid.Column="2" VerticalAlignment="Center" HorizontalAlignment="Left" TextElement.Foreground="{TemplateBinding Foreground}"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <EventTrigger RoutedEvent="MouseEnter">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="SidebarScale" Storyboard.TargetProperty="ScaleX" To="1.05" Duration="0:0:0.2"/>
                                        <DoubleAnimation Storyboard.TargetName="SidebarScale" Storyboard.TargetProperty="ScaleY" To="1.05" Duration="0:0:0.2"/>
                                        <ColorAnimation Storyboard.TargetName="Bd" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" To="#15888888" Duration="0:0:0.2"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                            <EventTrigger RoutedEvent="MouseLeave">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="SidebarScale" Storyboard.TargetProperty="ScaleX" To="1" Duration="0:0:0.2"/>
                                        <DoubleAnimation Storyboard.TargetName="SidebarScale" Storyboard.TargetProperty="ScaleY" To="1" Duration="0:0:0.2"/>
                                        <ColorAnimation Storyboard.TargetName="Bd" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" To="Transparent" Duration="0:0:0.3"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value> 
            </Setter>
        </Style>

        <Style x:Key="SidebarBtnAccent" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeAccent}"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="FontSize" Value="14"/> 
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Margin" Value="10,1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Bd" Background="{TemplateBinding Background}" CornerRadius="8" RenderTransformOrigin="0.5,0.5">
                            <Border.RenderTransform>
                                <ScaleTransform x:Name="AccentScale" ScaleX="1" ScaleY="1"/>
                            </Border.RenderTransform>
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="4"/><ColumnDefinition Width="40"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <Border Name="Indicator" Grid.Column="0" Width="3" Height="25" Background="Transparent" CornerRadius="1.5"/>
                                <TextBlock Name="btnIcon" Text="{TemplateBinding Tag}" Grid.Column="1" FontFamily="Segoe MDL2 Assets" FontSize="18" VerticalAlignment="Center" HorizontalAlignment="Center" Foreground="{TemplateBinding Foreground}"/>
                                <ContentPresenter Grid.Column="2" VerticalAlignment="Center" HorizontalAlignment="Left" TextElement.Foreground="{TemplateBinding Foreground}"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <EventTrigger RoutedEvent="MouseEnter">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="AccentScale" Storyboard.TargetProperty="ScaleX" To="1.05" Duration="0:0:0.2"/>
                                        <DoubleAnimation Storyboard.TargetName="AccentScale" Storyboard.TargetProperty="ScaleY" To="1.05" Duration="0:0:0.2"/>
                                        <ColorAnimation Storyboard.TargetName="Bd" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" To="#15888888" Duration="0:0:0.2"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                            <EventTrigger RoutedEvent="MouseLeave">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="AccentScale" Storyboard.TargetProperty="ScaleX" To="1" Duration="0:0:0.2"/>
                                        <DoubleAnimation Storyboard.TargetName="AccentScale" Storyboard.TargetProperty="ScaleY" To="1" Duration="0:0:0.2"/>
                                        <ColorAnimation Storyboard.TargetName="Bd" Storyboard.TargetProperty="(Border.Background).(SolidColorBrush.Color)" To="Transparent" Duration="0:0:0.3"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value> 
            </Setter>
        </Style>

        <Style x:Key="ActionBtn" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/> 
            <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
            <Setter Property="Height" Value="40"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="15,0"/>
            <Setter Property="BorderThickness" Value="{DynamicResource ThemeBorderThickness}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ThemeBorder}"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                         <Border Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="{DynamicResource ThemeCornerRadius}" RenderTransformOrigin="0.5,0.5">
                            <Border.RenderTransform>
                                <ScaleTransform x:Name="ActionScale" ScaleX="1" ScaleY="1"/>
                            </Border.RenderTransform>
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextBlock.FontWeight="Normal"/>
                         </Border>
                         <ControlTemplate.Triggers>
                            <EventTrigger RoutedEvent="MouseEnter">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="ActionScale" Storyboard.TargetProperty="ScaleX" To="1.05" Duration="0:0:0.15"/>
                                        <DoubleAnimation Storyboard.TargetName="ActionScale" Storyboard.TargetProperty="ScaleY" To="1.05" Duration="0:0:0.15"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                            <EventTrigger RoutedEvent="MouseLeave">
                                <BeginStoryboard>
                                    <Storyboard>
                                        <DoubleAnimation Storyboard.TargetName="ActionScale" Storyboard.TargetProperty="ScaleX" To="1" Duration="0:0:0.2"/>
                                        <DoubleAnimation Storyboard.TargetName="ActionScale" Storyboard.TargetProperty="ScaleY" To="1" Duration="0:0:0.2"/>
                                    </Storyboard>
                                </BeginStoryboard>
                            </EventTrigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{DynamicResource ThemeAccent}"/>
                                <Setter TargetName="Bd" Property="BorderBrush" Value="Transparent"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                         </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <!-- AI Button Style with Info Icon -->
        <Style x:Key="InfoBtnStyle" TargetType="Button">
            <Setter Property="Background" Value="#33888888"/>
            <Setter Property="Width" Value="24"/>
            <Setter Property="Height" Value="24"/>
            <Setter Property="Margin" Value="-25,0,0,0"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="InfoBd" Background="{TemplateBinding Background}" CornerRadius="12">
                            <TextBlock Text="" FontSize="14" Foreground="{DynamicResource ThemeAccent}" HorizontalAlignment="Center" VerticalAlignment="Center" FontWeight="Bold"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="InfoBd" Property="Background" Value="{DynamicResource ThemeAccent}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <Style x:Key="CardStyle" TargetType="Border">
            <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/>
            <Setter Property="CornerRadius" Value="{DynamicResource ThemeCornerRadius}"/>
            <Setter Property="Padding" Value="0"/>
            <Setter Property="Margin" Value="0,0,0,20"/>
            <Setter Property="Effect" Value="{StaticResource CardShadow}"/>
            <Setter Property="BorderThickness" Value="{DynamicResource ThemeBorderThickness}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource ThemeBorder}"/>
        </Style>
        
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="{DynamicResource ThemeSubText}"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" BorderThickness="0,0,0,2" BorderBrush="Transparent" Margin="0,0,10,0" Padding="10,5">
                            <ContentPresenter ContentSource="Header"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="BorderBrush" Value="{DynamicResource ThemeAccent}"/>
                                <Setter Property="Foreground" Value="{DynamicResource ThemeAccent}"/>
                                <Setter Property="FontWeight" Value="Bold"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="WinCtrlBtn" TargetType="Button">
            <Setter Property="Width" Value="45"/> <Setter Property="Height" Value="35"/>
            <Setter Property="Background" Value="Transparent"/> 
            <Setter Property="Foreground" Value="{DynamicResource ThemeWinCtrl}"/>
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Bd" Background="{TemplateBinding Background}">
                             <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="#22888888"/>
                                <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <Style x:Key="CloseBtn" TargetType="Button">
            <Setter Property="Width" Value="45"/>
            <Setter Property="Height" Value="35"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource ThemeWinCtrl}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="Bd" Background="{TemplateBinding Background}" CornerRadius="0,12,0,0">
                             <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="#E81123"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Window.Triggers>
        <EventTrigger RoutedEvent="Window.Loaded">
            <BeginStoryboard>
                <Storyboard>
                    <DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.0" To="1.0" Duration="0:0:0.6" />
                    <DoubleAnimation Storyboard.TargetName="MainScale" Storyboard.TargetProperty="ScaleX" From="0.95" To="1.0" Duration="0:0:0.6">
                        <DoubleAnimation.EasingFunction>
                            <CubicEase EasingMode="EaseOut"/>
                        </DoubleAnimation.EasingFunction>
                    </DoubleAnimation>
                    <DoubleAnimation Storyboard.TargetName="MainScale" Storyboard.TargetProperty="ScaleY" From="0.95" To="1.0" Duration="0:0:0.6">
                        <DoubleAnimation.EasingFunction>
                            <CubicEase EasingMode="EaseOut"/>
                        </DoubleAnimation.EasingFunction>
                    </DoubleAnimation>
                </Storyboard>
            </BeginStoryboard>
        </EventTrigger>
    </Window.Triggers>

    <!-- MAIN CONTAINER -->
    <Border Name="MainBorder" Background="{DynamicResource ThemeBg}" CornerRadius="{DynamicResource ThemeCornerRadius}" BorderBrush="{DynamicResource ThemeBorder}" BorderThickness="1" RenderTransformOrigin="0.5,0.5">
        <Border.RenderTransform>
            <ScaleTransform x:Name="MainScale" ScaleX="1" ScaleY="1"/>
        </Border.RenderTransform>
        <Grid Name="MainGrid">
            <Grid.ColumnDefinitions><ColumnDefinition Width="260"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

            <!-- SIDEBAR -->
            <Border Name="SidebarBorder" Grid.Column="0" Background="{DynamicResource ThemeSidebar}" CornerRadius="12,0,0,12">
                <Grid>
                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    
                    <StackPanel Grid.Row="0" Margin="0,18,0,12">
                        <!-- Logo -->
                        <Border Name="LogoBorder" Width="46" Height="46" CornerRadius="14" Background="{DynamicResource ThemeAccent}" HorizontalAlignment="Center" Margin="0,0,0,8">
                            <TextBlock Name="LogoIcon" Text="&#xE7F4;" FontFamily="Segoe MDL2 Assets" FontSize="22" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <TextBlock Name="AppTitle" Text="WinFlexOS" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" HorizontalAlignment="Center"/>
                        <TextBlock Text="V3.0 Ultimate" FontSize="10" Foreground="{DynamicResource ThemeSubText}" HorizontalAlignment="Center"/>
                    </StackPanel>

                    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="10,0">
                        <StackPanel Name="stkSidebar">
                            <TextBlock Name="lblGen" Text="GENERAL" FontSize="10" FontWeight="Bold" Foreground="{DynamicResource ThemeSubText}" Margin="15,0,0,4"/>

                            <Button Name="btnHome" Content="Dashboard" Tag="&#xE80F;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnAIBots" Content="AI &amp; Automation" Tag="&#xE99A;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnEssentials" Content="Essentials (CTT)" Tag="&#xE90F;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnUpdateMgr" Content="Update Manager" Tag="&#xE895;" Style="{StaticResource SidebarBtn}"/>

                            <TextBlock Name="lblSys" Text="SYSTEM" FontSize="10" FontWeight="Bold" Foreground="{DynamicResource ThemeSubText}" Margin="15,10,0,4"/>
                            <Button Name="btnWindowsTools" Content="Win Tools" Tag="&#xE7F8;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnSysInfoTools" Content="Hardware" Tag="&#xE946;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnTweaks" Content="Tweaks" Tag="&#xE790;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnMaintenance" Content="Cleanup" Tag="&#xE90C;" Style="{StaticResource SidebarBtn}"/>
                            <!-- NEON GLOW APPLIED -->
                            <Button Name="btnBeast" Content="System Health" Tag="&#xE946;" Style="{StaticResource SidebarBtn}" ToolTip="Advanced system diagnostics and repair center"/>

                            <TextBlock Name="lblAdv" Text="ADVANCED" FontSize="10" FontWeight="Bold" Foreground="{DynamicResource ThemeSubText}" Margin="15,10,0,4"/>
                            <Button Name="btnSecurity" Content="Security" Tag="&#xE72E;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnUserMgmt" Content="Users" Tag="&#xE779;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnKeyboardShortcuts" Content="Keyboard Shortcuts" Tag="&#xE92E;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnMusic" Content="Media Hub" Tag="&#xE8D6;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnIsraelTV" Content="Israel TV" Tag="&#xE7F5;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnGameCenter" Content="Gaming" Tag="&#xE7FC;" Style="{StaticResource SidebarBtn}"/>
                            <Button Name="btnPower" Content="Power" Tag="&#xE7E8;" Style="{StaticResource SidebarBtn}"/>

                        </StackPanel>
                    </ScrollViewer>
                    <StackPanel Grid.Row="2" Margin="15,6">
                        <TextBlock Text="Dev: WinFlexOS" FontSize="9" Foreground="{DynamicResource ThemeSubText}" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- CONTENT -->
            <Grid Grid.Column="1">
                <Grid.RowDefinitions><RowDefinition Height="60"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                
                <!-- TOP BAR -->
                <Border Name="TitleBar" Grid.Row="0" Background="Transparent" Margin="0,0,10,0">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>      <!-- Left Spacer -->
                            <ColumnDefinition Width="Auto"/>   <!-- Center Search -->
                            <ColumnDefinition Width="Auto"/>      <!-- Right Controls -->
                        </Grid.ColumnDefinitions>

                        <!-- CENTER: Rounded "Pill" Search Box -->
                        <Border Grid.Column="1" Width="400" Height="40" Background="{DynamicResource ThemeCardBg}" BorderBrush="{DynamicResource ThemeBorder}" BorderThickness="1" CornerRadius="20">
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="40"/></Grid.ColumnDefinitions>
                                
                                <TextBox Name="txtSearch" Grid.Column="0" Background="Transparent" Foreground="{DynamicResource ThemeFg}" BorderThickness="0" VerticalContentAlignment="Center" Padding="15,0,0,0" FontSize="14" CaretBrush="{DynamicResource ThemeFg}"/>
                                
                                <TextBlock Name="lblSearchPlaceholder" Grid.Column="0" Text="Search apps, settings and documents..." Foreground="{DynamicResource ThemeSubText}" VerticalAlignment="Center" Margin="18,0,0,0" IsHitTestVisible="False" Opacity="0.7"/>
                                
                                <Button Name="btnSearch" Grid.Column="1" Content="&#xE721;" FontFamily="Segoe MDL2 Assets" FontSize="16" Foreground="{DynamicResource ThemeAccent}" Background="Transparent" BorderThickness="0" Cursor="Hand" ToolTip="Click to search"/>
                            </Grid>
                        </Border>

                        <!-- RIGHT: Theme Selector & Window Controls -->
                        <StackPanel Grid.Column="2" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                            
                            <!-- LANGUAGE BUTTON (VISIBLE) -->
                            <Button Name="btnLang" Content="&#xE774;" Style="{StaticResource WinCtrlBtn}" Width="50" Height="40" Margin="0,0,20,0" FontSize="22" FontFamily="Segoe MDL2 Assets" Foreground="{DynamicResource ThemeWinCtrl}" ToolTip="Switch Hebrew/English"/>

                            <!-- Theme Text Larger -->
                            <TextBlock Name="lblThemeTxt" Text="Theme:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="{DynamicResource ThemeSubText}" FontSize="16"/>
                            <ComboBox Name="cmbThemes" Foreground="{DynamicResource ThemeFg}" Width="140" Height="32" FontSize="14" Margin="0,0,5,0"/>
                            <Button Name="btnThemeCustom" Content="&#xED25;" Style="{StaticResource WinCtrlBtn}" Width="32" Height="32" Margin="0,0,15,0" FontSize="18" Foreground="{DynamicResource ThemeWinCtrl}" Visibility="Collapsed" ToolTip="Change Custom Background" FontFamily="Segoe MDL2 Assets"/>
                            <Button Name="btnMin" Content="&#xE921;" Style="{StaticResource WinCtrlBtn}" Margin="10,0,0,0"/>
                            <Button Name="btnMax" Content="&#xE922;" Style="{StaticResource WinCtrlBtn}"/>
                            <Button Name="btnClose" Content="&#xE8BB;" Style="{StaticResource CloseBtn}"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- MAIN CONTENT AREA (Grid Row 1) -->
                <Grid Grid.Row="1">
                    <ScrollViewer Name="scrollMain" Margin="30,0,30,30" VerticalScrollBarVisibility="Auto">
                        <Grid Name="gridContent">
                            
                            <!-- 1. HOME -->
                            <!-- 1. HOME -->
                            <StackPanel Name="pnlHome" Visibility="Visible">
                                <!-- DYNAMIC DASHBOARD HEADER -->
                                <TextBlock Name="lblGreeting" Text="Good Evening, User" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" FontFamily="Segoe UI Variable Display, Segoe UI" Margin="0,0,0,16"/>

                                <!-- 2-COLUMN LAYOUT -->
                                <Grid Margin="0,0,0,18">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="2*"/>   <!-- Status + Bar Gauges -->
                                        <ColumnDefinition Width="20"/>   <!-- Spacer -->
                                        <ColumnDefinition Width="1.5*"/> <!-- Big Clock -->
                                    </Grid.ColumnDefinitions>
                                    
                                    <!-- LEFT CARD: SYSTEM STATUS + BARS (MERGED) -->
                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}">
                                        <Grid>
                                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                                            
                                            <!-- Dynamic Title Bar -->
                                            <Grid Grid.Row="0" Background="{DynamicResource ThemeTitleBg}" Margin="0,0,0,10">
                                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                                <TextBlock Name="lblSysStatus" Text=" System Status" FontSize="16" FontWeight="SemiBold" Foreground="{DynamicResource ThemeTitleFg}" VerticalAlignment="Center" Padding="5"/>
                                            </Grid>

                                            <Grid Grid.Row="1" Margin="15">
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>    <!-- Text Info -->
                                                    <ColumnDefinition Width="30"/>   <!-- Spacer -->
                                                    <ColumnDefinition Width="Auto"/> <!-- Bar Gauges -->
                                                </Grid.ColumnDefinitions>

                                                <!-- System Info Text -->
                                                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                                                    <TextBlock Name="txtSysInfo" Text="Analyzing..." Foreground="{DynamicResource ThemeFg}" FontSize="14" LineHeight="24"/>
                                                </StackPanel>

                                                <!-- Gauges Container (RAM + DISK) -->
                                                <Grid Grid.Column="2" VerticalAlignment="Center">
                                                    
                                                     <!-- MODERN RINGS (StrokeDashArray - perfectly aligned) -->
                                                    <StackPanel Name="pnlBarsModern" Visibility="{DynamicResource VisModern}" Orientation="Horizontal" HorizontalAlignment="Center">

                                                        <!-- RAM Ring -->
                                                        <StackPanel HorizontalAlignment="Center" Margin="0,0,24,0">
                                                            <Grid Width="96" Height="96">
                                                                <Ellipse Width="80" Height="80" Stroke="#333333" StrokeThickness="9" Fill="Transparent"/>
                                                                <Ellipse Name="arcRamFill" Width="80" Height="80"
                                                                         Stroke="{DynamicResource ThemeAccent}" StrokeThickness="9"
                                                                         Fill="Transparent" StrokeDashOffset="0"
                                                                         StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                                                                         RenderTransformOrigin="0.5,0.5">
                                                                    <Ellipse.RenderTransform><RotateTransform Angle="-90"/></Ellipse.RenderTransform>
                                                                </Ellipse>
                                                                <TextBlock Name="txtRamPercModern" Text="0%" FontSize="15" FontWeight="Bold"
                                                                           Foreground="{DynamicResource ThemeFg}"
                                                                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                                            </Grid>
                                                            <TextBlock Name="lblRamTxt" Text="RAM" FontSize="11"
                                                                       Foreground="{DynamicResource ThemeSubText}"
                                                                       HorizontalAlignment="Center" Margin="0,4,0,0"/>
                                                        </StackPanel>

                                                        <!-- Disk Ring -->
                                                        <StackPanel HorizontalAlignment="Center">
                                                            <Grid Width="96" Height="96">
                                                                <Ellipse Width="80" Height="80" Stroke="#333333" StrokeThickness="9" Fill="Transparent"/>
                                                                <Ellipse Name="arcDiskFill" Width="80" Height="80"
                                                                         Stroke="{DynamicResource ThemeAccent}" StrokeThickness="9"
                                                                         Fill="Transparent" StrokeDashOffset="0"
                                                                         StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                                                                         RenderTransformOrigin="0.5,0.5">
                                                                    <Ellipse.RenderTransform><RotateTransform Angle="-90"/></Ellipse.RenderTransform>
                                                                </Ellipse>
                                                                <TextBlock Name="txtDiskPercModern" Text="0%" FontSize="15" FontWeight="Bold"
                                                                           Foreground="{DynamicResource ThemeFg}"
                                                                           HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                                            </Grid>
                                                            <TextBlock Name="lblDiskTxt" Text="Disk C:" FontSize="11"
                                                                       Foreground="{DynamicResource ThemeSubText}"
                                                                       HorizontalAlignment="Center" Margin="0,4,0,0"/>
                                                        </StackPanel>

                                                        <Border Name="barRamFill"  Width="0" Height="0" Visibility="Collapsed"/>
                                                        <Border Name="barDiskFill" Width="0" Height="0" Visibility="Collapsed"/>
                                                    </StackPanel>

                                                    <!-- RETRO BARS (Win95 Style - PROTECTED) -->
                                                    <StackPanel Name="pnlBarsRetro" Visibility="{DynamicResource VisRetro}" Width="160">
                                                        
                                                        <!-- RAM Retro -->
                                                        <TextBlock Text="Memory Usage" FontSize="12" Foreground="Black" Margin="0,0,0,2"/>
                                                        <Border BorderThickness="1" BorderBrush="#808080" Background="White" Height="18" Margin="0,0,0,2">
                                                             <Rectangle Name="rectRamRetro" HorizontalAlignment="Left" Width="0" Fill="#000080" Height="16"/>
                                                        </Border>
                                                        <TextBlock Name="txtRamRetro" Text="0% Used" FontSize="10" Foreground="Black" Margin="0,0,0,10"/>

                                                        <!-- Disk Retro -->
                                                        <TextBlock Text="Disk Usage" FontSize="12" Foreground="Black" Margin="0,0,0,2"/>
                                                        <Border BorderThickness="1" BorderBrush="#808080" Background="White" Height="18">
                                                             <!-- CHANGED TO BLUE (#000080) FROM GREEN -->
                                                             <Rectangle Name="rectDiskRetro" HorizontalAlignment="Left" Width="0" Fill="#000080" Height="16"/>
                                                        </Border>
                                                        <TextBlock Name="txtDiskRetro" Text="0% Free" FontSize="10" Foreground="Black" Margin="0,2,0,0"/>
                                                    </StackPanel>

                                                </Grid>
                                            </Grid>
                                        </Grid>
                                    </Border>

                                    <!-- RIGHT CARD: SIMPLE CLOCK -->
                                    <Border Grid.Column="2" Style="{StaticResource CardStyle}">
                                        <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                            <TextBlock Name="lblTimeClock" Text="--:--" FontSize="72" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" HorizontalAlignment="Center" TextAlignment="Center" Width="380" FontFamily="Consolas"/>
                                            <TextBlock Name="lblDateClock" Text="..." FontSize="16" Foreground="{DynamicResource ThemeSubText}" HorizontalAlignment="Center" Margin="0,10,0,0"/>
                                        </StackPanel>
                                    </Border>

                                </Grid>

                                <!-- QUICK ACTIONS WITH TOOLTIPS -->
                                <TextBlock Name="lblQuickActions" Text="Quick Actions" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeTitleFg}" Margin="0,0,0,10"/>
                                
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="20"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>
                                    
                                    <!-- LEFT COLUMN: Main Quick Actions -->
                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblQuickActSubHeader" Text="System &amp; Maintenance" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="10"/>
                                                    <ColumnDefinition Width="*"/>
                                                </Grid.ColumnDefinitions>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="Auto"/>
                                                    <RowDefinition Height="5"/>
                                                    <RowDefinition Height="Auto"/>
                                                    <RowDefinition Height="5"/>
                                                    <RowDefinition Height="Auto"/>
                                                </Grid.RowDefinitions>
                                                
                                                <!-- Row 1 -->
                                                <Button Grid.Row="0" Grid.Column="0" Name="btnQuickCTT" Content="CTT WinUtil" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Launch CTT Utility"/>
                                                <Button Grid.Row="0" Grid.Column="2" Name="btnQuickUpdateMgr" Content="Update Manager" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Manage Windows Updates"/>
                                                
                                                <!-- Row 2 -->
                                                <Button Grid.Row="2" Grid.Column="0" Name="btnQuickUpdate" Content="Win Update" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Check for Updates"/>
                                                <Button Grid.Row="2" Grid.Column="2" Name="btnQuickClean" Content="Clean" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Disk Cleanup"/>

                                                <!-- Row 3 -->
                                                <Button Grid.Row="4" Grid.Column="0" Grid.ColumnSpan="3" Name="btnCreateDesktopShortcut" Content="Create Desktop Shortcut" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Create a CMD shortcut on Desktop to run this menu via IRM"/>
                                            </Grid>
                                        </StackPanel>
                                    </Border>
                                    
                                    <!-- RIGHT COLUMN: Control Panel & Devices -->
                                    <Border Grid.Column="2" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblQuickDevSubHeader" Text="Control Panel &amp; Devices" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Grid>
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="10"/>
                                                    <ColumnDefinition Width="*"/>
                                                </Grid.ColumnDefinitions>
                                                <Grid.RowDefinitions>
                                                    <RowDefinition Height="Auto"/>
                                                    <RowDefinition Height="5"/>
                                                    <RowDefinition Height="Auto"/>
                                                    <RowDefinition Height="5"/>
                                                    <RowDefinition Height="Auto"/>
                                                </Grid.RowDefinitions>
                                                
                                                <!-- Row 1 -->
                                                <Button Grid.Row="0" Grid.Column="0" Name="btnQuickCP" Content="Control Panel" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Control Panel Classic"/>
                                                <Button Grid.Row="0" Grid.Column="2" Name="btnQuickSettings" Content="Settings" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Modern Settings"/>
                                                
                                                <!-- Row 2 -->
                                                <Button Grid.Row="2" Grid.Column="0" Name="btnQuickDevicesClassic" Content="Devices (Old)" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Devices &amp; Printers"/>
                                                <Button Grid.Row="2" Grid.Column="2" Name="btnQuickDevicesModern" Content="Devices (New)" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Bluetooth &amp; Devices"/>
                                                
                                                <!-- Row 3 -->
                                                <Button Grid.Row="4" Grid.Column="0" Name="btnQuickDevMgr" Content="Device Manager" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Device Manager"/>
                                                <Button Grid.Row="4" Grid.Column="2" Name="btnQuickPrintMgmt" Content="Print Mgmt" Height="36" Style="{StaticResource ActionBtn}" ToolTip="Print Management"/>
                                            </Grid>
                                        </StackPanel>
                                    </Border>
                                </Grid>

                                <!-- CATEGORYEXPLAINER: BUBBLES GRID -->
                                <TextBlock Name="lblBubblesHeader" Text="Category Guide" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeTitleFg}" Margin="0,6,0,10"/>
                                
                                <Border Style="{StaticResource CardStyle}" Padding="14">
                                    <ItemsControl>
                                        <ItemsControl.ItemsPanel>
                                            <ItemsPanelTemplate>
                                                <UniformGrid Columns="6"/>
                                            </ItemsPanelTemplate>
                                        </ItemsControl.ItemsPanel>
                                        
                                        <!-- Helper Style for Bubbles (NOW BUTTONS) -->
                                        <ItemsControl.Resources>
                                            <Style TargetType="Button" x:Key="BubbleBtnStyle">
                                                <Setter Property="Background" Value="{DynamicResource ThemeCardBg}"/>
                                                <Setter Property="BorderBrush" Value="{DynamicResource ThemeBorder}"/>
                                                <Setter Property="BorderThickness" Value="1"/>
                                                <Setter Property="Margin" Value="4"/>
                                                <Setter Property="Height" Value="74"/>
                                                <Setter Property="Cursor" Value="Hand"/>
                                                <Setter Property="Template">
                                                    <Setter.Value>
                                                        <ControlTemplate TargetType="Button">
                                                            <Border Background="{TemplateBinding Background}" 
                                                                    BorderBrush="{TemplateBinding BorderBrush}" 
                                                                    BorderThickness="{TemplateBinding BorderThickness}" 
                                                                    CornerRadius="12" Padding="8">
                                                                <ContentPresenter/>
                                                            </Border>
                                                        </ControlTemplate>
                                                    </Setter.Value>
                                                </Setter>
                                            </Style>
                                            
                                            <Style TargetType="TextBlock" x:Key="BubbleTitle">
                                                <Setter Property="FontWeight" Value="Bold"/>
                                                <Setter Property="Foreground" Value="{DynamicResource ThemeAccent}"/>
                                                <Setter Property="HorizontalAlignment" Value="Center"/>
                                                <Setter Property="Margin" Value="0,0,0,4"/>
                                            </Style>
                                            <Style TargetType="TextBlock" x:Key="BubbleDesc">
                                                <Setter Property="FontSize" Value="11"/>
                                                <Setter Property="Foreground" Value="{DynamicResource ThemeSubText}"/>
                                                <Setter Property="TextWrapping" Value="Wrap"/>
                                                <Setter Property="TextAlignment" Value="Center"/>
                                                <Setter Property="HorizontalAlignment" Value="Center"/>
                                            </Style>
                                        </ItemsControl.Resources>

                                        <!-- 1. AI Bots -->
                                        <Button Name="btnBubAI" Style="{StaticResource BubbleBtnStyle}">
                                            <Grid>
                                                <StackPanel VerticalAlignment="Center">
                                                    <TextBlock Name="lblBubAITitle" Text="AI Bots" Style="{StaticResource BubbleTitle}"/>
                                                    <TextBlock Name="lblBubAIDesc" Text="Access ChatGPT, Gemini &amp; smart tools" Style="{StaticResource BubbleDesc}"/>
                                                </StackPanel>
                                                <!-- Info Button -->
                                                <Button Name="btnAIInfo" Content="&#xE946;" FontFamily="Segoe MDL2 Assets" Foreground="{DynamicResource ThemeAccent}" Width="20" Height="20" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,-4,-4,0" Cursor="Hand" ToolTip="AI Hub Information" Background="Transparent" BorderThickness="0" FontSize="12"/>
                                            </Grid>
                                        </Button>

                                        <!-- 2. CTT Tools -->
                                        <Button Name="btnBubCTT" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubCTTTitle" Text="CTT Tools" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubCTTDesc" Text="System utilities &amp; installation helpers" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 3. Israel TV -->
                                        <Button Name="btnBubTV" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubTVTitle" Text="Israel TV" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubTVDesc" Text="Watch live Israeli TV channels" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 4. Update Mgr -->
                                        <Button Name="btnBubUpd" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubUpdTitle" Text="Updates" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubUpdDesc" Text="Check updates, history &amp; fixes" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 5. Hardware -->
                                        <Button Name="btnBubHw" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubHwTitle" Text="Hardware" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubHwDesc" Text="Full specs (CPU, RAM, GPU)" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 6. Windows Tools -->
                                        <Button Name="btnBubWin" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubWinTitle" Text="Windows" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubWinDesc" Text="Built-in tools (Control Panel, CMD)" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 7. Tweaks -->
                                        <Button Name="btnBubTwk" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubTwkTitle" Text="Tweaks" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubTwkDesc" Text="Boost performance &amp; customize UI" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 8. Cleanup -->
                                        <Button Name="btnBubCln" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubClnTitle" Text="Cleanup" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubClnDesc" Text="Free space, clear cache &amp; junk" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 9. Security -->
                                        <Button Name="btnBubSec" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubSecTitle" Text="Security" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubSecDesc" Text="Antivirus, Firewall &amp; Privacy" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 10. Music -->
                                        <Button Name="btnBubMus" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubMusTitle" Text="Music" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubMusDesc" Text="Music player, playlists &amp; radio" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 11. Gaming -->
                                        <Button Name="btnBubGame" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubGameTitle" Text="Gaming" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubGameDesc" Text="Game scanner, launchers &amp; FPS boost" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>

                                        <!-- 12. Beast Mode -->
                                        <Button Name="btnBubBst" Style="{StaticResource BubbleBtnStyle}">
                                            <StackPanel VerticalAlignment="Center">
                                                <TextBlock Name="lblBubBstTitle" Text="Beast Mode" Style="{StaticResource BubbleTitle}"/>
                                                <TextBlock Name="lblBubBstDesc" Text="Advanced tools &amp; full optimization" Style="{StaticResource BubbleDesc}"/>
                                            </StackPanel>
                                        </Button>
                                    </ItemsControl>
                                </Border>
                            </StackPanel>

                            <!-- 2. AI HUB (FULL) -->
                            <StackPanel Name="pnlAIBots" Visibility="Collapsed">
                                <TextBlock Name="lblAIHeader" Text="AI &amp; Automation Hub" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Leading LLMs (Chat)" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnGPT" Content="ChatGPT (OpenAI)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ChatGPT (OpenAI)"/>
                                            <Button Name="btnGemini" Content="Google Gemini" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Google Gemini"/>
                                            <Button Name="btnCopilot" Content="Microsoft Copilot" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Microsoft Copilot"/>
                                            <Button Name="btnClaude" Content="Claude AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Claude AI"/>
                                            <Button Name="btnGrok" Content="Grok (xAI)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Grok (xAI)"/>
                                            <Button Name="btnMistral" Content="Mistral AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Mistral AI"/>
                                            <Button Name="btnLlama" Content="Meta AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Meta AI"/>
                                            <Button Name="btnPoe" Content="Poe (Quora)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Poe (Quora)"/>
                                            <Button Name="btnYouChat" Content="You.com" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch You.com"/>
                                            <Button Name="btnCohere" Content="Cohere" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Cohere"/>
                                            <Button Name="btnPI" Content="Pi (Inflection)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Pi (Inflection)"/>
                                            <Button Name="btnJasper" Content="Jasper AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Jasper AI"/>
                                            <Button Name="btnCharacter" Content="Character.AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Character.AI"/>
                                            <Button Name="btnReplika" Content="Replika" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Replika"/>
                                            <Button Name="btnHuggingChat" Content="HuggingChat" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch HuggingChat"/>
                                            <Button Name="btnGroq" Content="Groq" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Groq"/>
                                            <Button Name="btnOpenRouter" Content="OpenRouter" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch OpenRouter"/>
                                            <Button Name="btnOllama" Content="Ollama" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ollama"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Search &amp; Research" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnPerplexity" Content="Perplexity AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Perplexity AI"/>
                                            <Button Name="btnPhind" Content="Phind" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Phind"/>
                                            <Button Name="btnKagi" Content="Kagi" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Kagi"/>
                                            <Button Name="btnWolframAlpha" Content="Wolfram Alpha" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Wolfram Alpha"/>
                                            <Button Name="btnConsensus" Content="Consensus" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Consensus"/>
                                            <Button Name="btnElicit" Content="Elicit" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Elicit"/>
                                            <Button Name="btnScholar" Content="Semantic Scholar" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Semantic Scholar"/>
                                            <Button Name="btnSciSpace" Content="SciSpace" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch SciSpace"/>
                                            <Button Name="btnConnected" Content="Connected Papers" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Connected Papers"/>
                                            <Button Name="btnScite" Content="Scite.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Scite.ai"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Coding &amp; Development" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnGitHubCopilot" Content="GitHub Copilot" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch GitHub Copilot"/>
                                            <Button Name="btnCursor" Content="Cursor IDE" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Cursor IDE"/>
                                            <Button Name="btnReplit" Content="Replit AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Replit AI"/>
                                            <Button Name="btnBlackbox" Content="Blackbox AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Blackbox AI"/>
                                            <Button Name="btnDeepSeek" Content="DeepSeek" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DeepSeek"/>
                                            <Button Name="btnCodeium" Content="Codeium" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Codeium"/>
                                            <Button Name="btnTabnine" Content="Tabnine" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tabnine"/>
                                            <Button Name="btnAmazonQ" Content="Amazon Q" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Amazon Q"/>
                                            <Button Name="btnV0" Content="v0.dev (UI)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch v0.dev (UI)"/>
                                            <Button Name="btnBolt" Content="Bolt.new" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Bolt.new"/>
                                            <Button Name="btnLovable" Content="Lovable" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Lovable"/>
                                            <Button Name="btnHuggingFace" Content="Hugging Face" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Hugging Face"/>
                                            <Button Name="btnCodeSandbox" Content="CodeSandbox AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch CodeSandbox AI"/>
                                            <Button Name="btnStackBlitz" Content="StackBlitz" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch StackBlitz"/>
                                            <Button Name="btnSourceGraph" Content="Sourcegraph Cody" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Sourcegraph Cody"/>
                                            <Button Name="btnAider" Content="Aider" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Aider"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Image Generation" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnNanoBanana" Content=" Nano Banana Prompter" Width="220" Background="{DynamicResource ThemeAccent}" Foreground="White" Style="{StaticResource ActionBtn}" ToolTip="  !      AI.      ."/>
                                            <Button Name="btnMidjourney" Content="Midjourney" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Midjourney"/>
                                            <Button Name="btnDALLE" Content="DALL-E 3" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DALL-E 3"/>
                                            <Button Name="btnBingImage" Content="Bing Create" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Bing Create"/>
                                            <Button Name="btnLeonardo" Content="Leonardo.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Leonardo.ai"/>
                                            <Button Name="btnIdeogram" Content="Ideogram" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ideogram"/>
                                            <Button Name="btnFlux" Content="Flux (BFL)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Flux (BFL)"/>
                                            <Button Name="btnStableDiff" Content="Stable Diffusion" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Stable Diffusion"/>
                                            <Button Name="btnPlayground" Content="Playground AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Playground AI"/>
                                            <Button Name="btnNightCafe" Content="NightCafe" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch NightCafe"/>
                                            <Button Name="btnCivitai" Content="Civitai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Civitai"/>
                                            <Button Name="btnSeaArt" Content="SeaArt" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch SeaArt"/>
                                            <Button Name="btnTensor" Content="Tensor.art" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tensor.art"/>
                                            <Button Name="btnKrea" Content="Krea AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Krea AI"/>
                                            <Button Name="btnFirefly" Content="Adobe Firefly" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Adobe Firefly"/>
                                            <Button Name="btnCanvaAI" Content="Canva AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Canva AI"/>
                                            <Button Name="btnRemoveBg" Content="Remove.bg" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Remove.bg"/>
                                            <Button Name="btnClipDrop" Content="ClipDrop" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ClipDrop"/>
                                            <Button Name="btnPhotoRoom" Content="PhotoRoom" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch PhotoRoom"/>
                                            <Button Name="btnMagnific" Content="Magnific" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Magnific"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Video Generation" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnSora" Content="Sora (OpenAI)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Sora (OpenAI)"/>
                                            <Button Name="btnRunway" Content="Runway Gen-3" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Runway Gen-3"/>
                                            <Button Name="btnPika" Content="Pika Labs" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Pika Labs"/>
                                            <Button Name="btnLuma" Content="Luma Dream" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Luma Dream"/>
                                            <Button Name="btnKling" Content="Kling AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Kling AI"/>
                                            <Button Name="btnVeo" Content="Veo (Google)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Veo (Google)"/>
                                            <Button Name="btnMinimax" Content="Minimax Hailuo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Minimax Hailuo"/>
                                            <Button Name="btnHeyGen" Content="HeyGen" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch HeyGen"/>
                                            <Button Name="btnSynthesia" Content="Synthesia" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Synthesia"/>
                                            <Button Name="btnDescript" Content="Descript" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Descript"/>
                                            <Button Name="btnCapCut" Content="CapCut" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch CapCut"/>
                                            <Button Name="btnPictory" Content="Pictory" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Pictory"/>
                                            <Button Name="btnInVideo" Content="InVideo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch InVideo"/>
                                            <Button Name="btnFliki" Content="Fliki" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Fliki"/>
                                            <Button Name="btnD_ID" Content="D-ID" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch D-ID"/>
                                            <Button Name="btnWonder" Content="Wonder Dynamics" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Wonder Dynamics"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Audio &amp; Music" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnSuno" Content="Suno AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Suno AI"/>
                                            <Button Name="btnUdio" Content="Udio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Udio"/>
                                            <Button Name="btnElevenLabs" Content="ElevenLabs" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ElevenLabs"/>
                                            <Button Name="btnMubert" Content="Mubert" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Mubert"/>
                                            <Button Name="btnSoundraw" Content="Soundraw" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Soundraw"/>
                                            <Button Name="btnBoomy" Content="Boomy" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Boomy"/>
                                            <Button Name="btnAiva" Content="AIVA" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch AIVA"/>
                                            <Button Name="btnSplice" Content="Splice" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Splice"/>
                                            <Button Name="btnLalal" Content="LALAL.AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch LALAL.AI"/>
                                            <Button Name="btnVoiceMod" Content="Voicemod" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Voicemod"/>
                                            <Button Name="btnAdobePodcast" Content="Adobe Podcast" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Adobe Podcast"/>
                                            <Button Name="btnDescript2" Content="Descript Audio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Descript Audio"/>
                                            <Button Name="btnSpeechify" Content="Speechify" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Speechify"/>
                                            <Button Name="btnPlay_ht" Content="Play.ht" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Play.ht"/>
                                            <Button Name="btnWellSaid" Content="WellSaid Labs" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch WellSaid Labs"/>
                                            <Button Name="btnResemble" Content="Resemble AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Resemble AI"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Writing &amp; Content" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnGrammarly" Content="Grammarly" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Grammarly"/>
                                            <Button Name="btnCopy_ai" Content="Copy.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Copy.ai"/>
                                            <Button Name="btnWritesonic" Content="Writesonic" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Writesonic"/>
                                            <Button Name="btnRytr" Content="Rytr" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Rytr"/>
                                            <Button Name="btnSudowrite" Content="Sudowrite" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Sudowrite"/>
                                            <Button Name="btnNovelAI" Content="NovelAI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch NovelAI"/>
                                            <Button Name="btnWordtune" Content="Wordtune" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Wordtune"/>
                                            <Button Name="btnQuillBot" Content="QuillBot" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch QuillBot"/>
                                            <Button Name="btnHyperwrite" Content="HyperWrite" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch HyperWrite"/>
                                            <Button Name="btnTextCortex" Content="TextCortex" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch TextCortex"/>
                                            <Button Name="btnINK" Content="INK Editor" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch INK Editor"/>
                                            <Button Name="btnFrase" Content="Frase" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Frase"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Productivity &amp; Business" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnNotebookLM" Content="NotebookLM" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch NotebookLM"/>
                                            <Button Name="btnGamma" Content="Gamma" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Gamma"/>
                                            <Button Name="btnTome" Content="Tome" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tome"/>
                                            <Button Name="btnBeautiful" Content="Beautiful.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Beautiful.ai"/>
                                            <Button Name="btnNotion" Content="Notion AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Notion AI"/>
                                            <Button Name="btnClickUp" Content="ClickUp AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ClickUp AI"/>
                                            <Button Name="btnZapier" Content="Zapier" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Zapier"/>
                                            <Button Name="btnMake" Content="Make (Integromat)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Make (Integromat)"/>
                                            <Button Name="btnOtter" Content="Otter.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Otter.ai"/>
                                            <Button Name="btnFireflies" Content="Fireflies" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Fireflies"/>
                                            <Button Name="btnReclaim" Content="Reclaim AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Reclaim AI"/>
                                            <Button Name="btnMotion" Content="Motion" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Motion"/>
                                            <Button Name="btnMem" Content="Mem.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Mem.ai"/>
                                            <Button Name="btnCraft" Content="Craft" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Craft"/>
                                            <Button Name="btnCoda" Content="Coda AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Coda AI"/>
                                            <Button Name="btnAirtable" Content="Airtable AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Airtable AI"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" 3D &amp; Gaming" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnMeshy" Content="Meshy" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Meshy"/>
                                            <Button Name="btnTripo" Content="Tripo AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tripo AI"/>
                                            <Button Name="btnCSM" Content="CSM (Cube)" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch CSM (Cube)"/>
                                            <Button Name="btnLuma3D" Content="Luma Genie" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Luma Genie"/>
                                            <Button Name="btnKaedim" Content="Kaedim" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Kaedim"/>
                                            <Button Name="btnSpline" Content="Spline AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Spline AI"/>
                                            <Button Name="btnAlpha3D" Content="Alpha3D" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Alpha3D"/>
                                            <Button Name="btnScenario" Content="Scenario" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Scenario"/>
                                            <Button Name="btnPromethean" Content="Promethean AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Promethean AI"/>
                                            <Button Name="btnInworld" Content="Inworld" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Inworld"/>
                                            <Button Name="btnConvai" Content="Convai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Convai"/>
                                            <Button Name="btnRobloxAI" Content="Roblox AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Roblox AI"/>
                                            <Button Name="btnPoint_E" Content="Point-E" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Point-E"/>
                                            <Button Name="btnGetFloorplan" Content="GetFloorPlan" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch GetFloorPlan"/>
                                            <Button Name="btnPlanner5D" Content="Planner 5D" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Planner 5D"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Data &amp; Analytics" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnJulius" Content="Julius AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Julius AI"/>
                                            <Button Name="btnChatCSV" Content="ChatCSV" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ChatCSV"/>
                                            <Button Name="btnRowsAI" Content="Rows AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Rows AI"/>
                                            <Button Name="btnChannel" Content="Channel" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Channel"/>
                                            <Button Name="btnOsmo" Content="Osmo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Osmo"/>
                                            <Button Name="btnMonkeyLearn" Content="MonkeyLearn" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch MonkeyLearn"/>
                                            <Button Name="btnObviouslyAI" Content="Obviously AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Obviously AI"/>
                                            <Button Name="btnAkkio" Content="Akkio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Akkio"/>
                                            <Button Name="btnMindsDB" Content="MindsDB" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch MindsDB"/>
                                            <Button Name="btnDataRobot" Content="DataRobot" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DataRobot"/>
                                            <Button Name="btnH2O" Content="H2O.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch H2O.ai"/>
                                            <Button Name="btnRapidMiner" Content="RapidMiner" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch RapidMiner"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Education &amp; Learning" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnKhanmigo" Content="Khanmigo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Khanmigo"/>
                                            <Button Name="btnDuolingo" Content="Duolingo Max" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Duolingo Max"/>
                                            <Button Name="btnQuizlet" Content="Quizlet AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Quizlet AI"/>
                                            <Button Name="btnSocratic" Content="Socratic" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Socratic"/>
                                            <Button Name="btnPhotomath" Content="Photomath" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Photomath"/>
                                            <Button Name="btnWolfram" Content="Wolfram Alpha" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Wolfram Alpha"/>
                                            <Button Name="btnChegg" Content="Chegg AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Chegg AI"/>
                                            <Button Name="btnCourseHero" Content="Course Hero" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Course Hero"/>
                                            <Button Name="btnSynthesia2" Content="Synthesia Edu" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Synthesia Edu"/>
                                            <Button Name="btnMagicSchool" Content="MagicSchool" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch MagicSchool"/>
                                            <Button Name="btnEducoAI" Content="Educo AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Educo AI"/>
                                            <Button Name="btnQuestionwell" Content="Questionwell" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Questionwell"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Science &amp; Research" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnAlphaFold" Content="AlphaFold" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch AlphaFold"/>
                                            <Button Name="btnGalactica" Content="Galactica" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Galactica"/>
                                            <Button Name="btnConsensus2" Content="Consensus" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Consensus"/>
                                            <Button Name="btnResearchRabbit" Content="ResearchRabbit" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ResearchRabbit"/>
                                            <Button Name="btnIris" Content="Iris.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Iris.ai"/>
                                            <Button Name="btnLitmaps" Content="Litmaps" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Litmaps"/>
                                            <Button Name="btnInciteful" Content="Inciteful" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Inciteful"/>
                                            <Button Name="btnOpenRead" Content="OpenRead" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch OpenRead"/>
                                            <Button Name="btnChatPDF" Content="ChatPDF" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ChatPDF"/>
                                            <Button Name="btnPDFAI" Content="PDF.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch PDF.ai"/>
                                            <Button Name="btnExplainpaper" Content="Explainpaper" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Explainpaper"/>
                                            <Button Name="btnPaperBrain" Content="PaperBrain" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch PaperBrain"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Social &amp; Marketing" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnBuffer" Content="Buffer AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Buffer AI"/>
                                            <Button Name="btnHootsuite" Content="Hootsuite AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Hootsuite AI"/>
                                            <Button Name="btnLater" Content="Later AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Later AI"/>
                                            <Button Name="btnOcoya" Content="Ocoya" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ocoya"/>
                                            <Button Name="btnPredis" Content="Predis.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Predis.ai"/>
                                            <Button Name="btnFlick" Content="Flick" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Flick"/>
                                            <Button Name="btnViralPost" Content="ViralPost" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ViralPost"/>
                                            <Button Name="btnTweetHunter" Content="Tweet Hunter" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tweet Hunter"/>
                                            <Button Name="btnHypefury" Content="Hypefury" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Hypefury"/>
                                            <Button Name="btnTypefully" Content="Typefully" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Typefully"/>
                                            <Button Name="btnTaplio" Content="Taplio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Taplio"/>
                                            <Button Name="btnAuthority" Content="AuthoredUp" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch AuthoredUp"/>
                                            <Button Name="btnPhotofeeler" Content="Photofeeler" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Photofeeler"/>
                                            <Button Name="btnBrandMark" Content="BrandMark" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch BrandMark"/>
                                            <Button Name="btnLooka" Content="Looka" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Looka"/>
                                            <Button Name="btnHatchful" Content="Hatchful" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Hatchful"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Legal &amp; Finance" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnHarvey" Content="Harvey AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Harvey AI"/>
                                            <Button Name="btnCasetext" Content="Casetext" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Casetext"/>
                                            <Button Name="btnLexMachina" Content="Lex Machina" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Lex Machina"/>
                                            <Button Name="btnDocuSign" Content="DocuSign AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DocuSign AI"/>
                                            <Button Name="btnIronclad" Content="Ironclad" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ironclad"/>
                                            <Button Name="btnSpellbook" Content="Spellbook" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Spellbook"/>
                                            <Button Name="btnKira" Content="Kira Systems" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Kira Systems"/>
                                            <Button Name="btnBloomberg" Content="Bloomberg GPT" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Bloomberg GPT"/>
                                            <Button Name="btnAlphaSense" Content="AlphaSense" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch AlphaSense"/>
                                            <Button Name="btnKensho" Content="Kensho" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Kensho"/>
                                            <Button Name="btnAyasdi" Content="Ayasdi" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ayasdi"/>
                                            <Button Name="btnZest" Content="Zest AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Zest AI"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" E-commerce &amp; Sales" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnShopify" Content="Shopify Magic" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Shopify Magic"/>
                                            <Button Name="btnAmazonSeller" Content="Amazon Seller AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Amazon Seller AI"/>
                                            <Button Name="btnDescriptProd" Content="Descript Prod" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Descript Prod"/>
                                            <Button Name="btnCratejoy" Content="Cratejoy" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Cratejoy"/>
                                            <Button Name="btnOberlo" Content="Oberlo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Oberlo"/>
                                            <Button Name="btnSalesforce" Content="Salesforce AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Salesforce AI"/>
                                            <Button Name="btnGong" Content="Gong.io" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Gong.io"/>
                                            <Button Name="btnChorus" Content="Chorus" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Chorus"/>
                                            <Button Name="btnOutreach" Content="Outreach" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Outreach"/>
                                            <Button Name="btnApollo" Content="Apollo.io" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Apollo.io"/>
                                            <Button Name="btnSeamless" Content="Seamless.AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Seamless.AI"/>
                                            <Button Name="btnLusha" Content="Lusha" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Lusha"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Customer &amp; Support" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnIntercom" Content="Intercom Fin" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Intercom Fin"/>
                                            <Button Name="btnZendesk" Content="Zendesk AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Zendesk AI"/>
                                            <Button Name="btnFreshdesk" Content="Freshdesk" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Freshdesk"/>
                                            <Button Name="btnDrift" Content="Drift" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Drift"/>
                                            <Button Name="btnAda" Content="Ada" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ada"/>
                                            <Button Name="btnChatbase" Content="Chatbase" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Chatbase"/>
                                            <Button Name="btnBotpress" Content="Botpress" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Botpress"/>
                                            <Button Name="btnLandbot" Content="Landbot" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Landbot"/>
                                            <Button Name="btnTidio" Content="Tidio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Tidio"/>
                                            <Button Name="btnCrisp" Content="Crisp" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Crisp"/>
                                            <Button Name="btnManyChat" Content="ManyChat" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch ManyChat"/>
                                            <Button Name="btnChatfuel" Content="Chatfuel" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Chatfuel"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Developer Tools" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnOpenAIAPI" Content="OpenAI API" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch OpenAI API"/>
                                            <Button Name="btnAnthropic" Content="Anthropic API" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Anthropic API"/>
                                            <Button Name="btnGoogleAI" Content="Google AI Studio" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Google AI Studio"/>
                                            <Button Name="btnReplicate" Content="Replicate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Replicate"/>
                                            <Button Name="btnModal" Content="Modal" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Modal"/>
                                            <Button Name="btnBananaML" Content="Banana" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Banana"/>
                                            <Button Name="btnRunpod" Content="RunPod" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch RunPod"/>
                                            <Button Name="btnVastAI" Content="Vast.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Vast.ai"/>
                                            <Button Name="btnLambdaLabs" Content="Lambda Labs" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Lambda Labs"/>
                                            <Button Name="btnWeights" Content="Weights/Biases" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Weights/Biases"/>
                                            <Button Name="btnMLflow" Content="MLflow" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch MLflow"/>
                                            <Button Name="btnDVC" Content="DVC" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DVC"/>
                                            <Button Name="btnLangChain" Content="LangChain" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch LangChain"/>
                                            <Button Name="btnLlamaIndex" Content="LlamaIndex" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch LlamaIndex"/>
                                            <Button Name="btnPinecone" Content="Pinecone" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Pinecone"/>
                                            <Button Name="btnWeaviate" Content="Weaviate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Weaviate"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Translation &amp; Language" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnDeepL" Content="DeepL" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch DeepL"/>
                                            <Button Name="btnGoogleTranslate" Content="Google Translate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Google Translate"/>
                                            <Button Name="btnPapago" Content="Papago" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Papago"/>
                                            <Button Name="btnReverso" Content="Reverso" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Reverso"/>
                                            <Button Name="btnLinguee" Content="Linguee" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Linguee"/>
                                            <Button Name="btnYandex" Content="Yandex Translate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Yandex Translate"/>
                                            <Button Name="btnBaidu" Content="Baidu Translate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Baidu Translate"/>
                                            <Button Name="btnInstant" Content="Instant" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Instant"/>
                                            <Button Name="btnHeygen2" Content="HeyGen Translate" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch HeyGen Translate"/>
                                            <Button Name="btnRask" Content="Rask.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Rask.ai"/>
                                            <Button Name="btnCaption" Content="Captions" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Captions"/>
                                            <Button Name="btnSubtitle" Content="Subtitle.ai" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Subtitle.ai"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text=" Fun &amp; Creative" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnAvatar" Content="Ready Player Me" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Ready Player Me"/>
                                            <Button Name="btnLensa" Content="Lensa" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Lensa"/>
                                            <Button Name="btnDawn" Content="Dawn AI" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Dawn AI"/>
                                            <Button Name="btnRemini" Content="Remini" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Remini"/>
                                            <Button Name="btnFaceApp" Content="FaceApp" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch FaceApp"/>
                                            <Button Name="btnReface" Content="Reface" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Reface"/>
                                            <Button Name="btnWombo" Content="Wombo" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Wombo"/>
                                            <Button Name="btnMyHeritage" Content="MyHeritage" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch MyHeritage"/>
                                            <Button Name="btnArtbreeder" Content="Artbreeder" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Artbreeder"/>
                                            <Button Name="btnDeepDream" Content="Deep Dream" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Deep Dream"/>
                                            <Button Name="btnNeuralStyle" Content="Neural Style" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch Neural Style"/>
                                            <Button Name="btnPrisonner" Content="This X Does Not Exist" Width="150" Style="{StaticResource ActionBtn}" ToolTip="Launch This X Does Not Exist"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- NEW: NANO BANANA PANEL (INTEGRATED) -->
                            <StackPanel Name="pnlNanoBanana" Visibility="Collapsed">
                                <StackPanel Orientation="Horizontal" Margin="0,0,0,20">
                                    <Button Name="btnBackToAI" Content=" Back" Width="100" Style="{StaticResource ActionBtn}"/>
                                    <TextBlock Text="Nano Banana Image Prompter" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="20,0,0,0" VerticalAlignment="Center"/>
                                </StackPanel>

                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/> <!-- Left: Generators -->
                                        <ColumnDefinition Width="30"/> <!-- Spacer -->
                                        <ColumnDefinition Width="300"/> <!-- Right: Settings -->
                                    </Grid.ColumnDefinitions>

                                    <!-- LEFT COLUMN -->
                                    <StackPanel Grid.Column="0">
                                        <!-- 1. Quick Random -->
                                        <Border Style="{StaticResource CardStyle}">
                                            <StackPanel>
                                                <TextBlock Text="Quick Random Generation" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                <TextBlock Text="Instant creation - Click to Launch Browser" Foreground="{DynamicResource ThemeSubText}" Margin="0,0,0,15"/>
                                                
                                                <WrapPanel>
                                                    <Button Name="btnGenHebrew" Content="Random Hebrew" Width="200" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnGenEnglish" Content="Random English" Width="200" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSurpriseMe" Content="Surprise Me!" Width="220" Style="{StaticResource ActionBtn}" Background="{DynamicResource ThemeAccent}" Foreground="White" FontWeight="Bold"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- 2. Style Roulette -->
                                        <Border Style="{StaticResource CardStyle}">
                                            <StackPanel>
                                                <TextBlock Text="Style Roulette" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                <TextBlock Text="Pick a specific style, get a random subject." Foreground="{DynamicResource ThemeSubText}" Margin="0,0,0,15"/>

                                                <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                                    <RadioButton Name="rbHebrew" Content="Hebrew" Foreground="{DynamicResource ThemeFg}" FontSize="14" IsChecked="True" Margin="0,0,20,0"/>
                                                    <RadioButton Name="rbEnglish" Content="English" Foreground="{DynamicResource ThemeFg}" FontSize="14"/>
                                                </StackPanel>

                                                <ComboBox Name="cmbStyles" Height="40" Margin="0,0,0,10"/>
                                                <Button Name="btnSpinRoulette" Content="Spin &amp; Launch" Width="200" HorizontalAlignment="Left" Style="{StaticResource ActionBtn}"/>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- 3. Custom Input -->
                                        <Border Style="{StaticResource CardStyle}">
                                            <StackPanel>
                                                <TextBlock Text="Custom Request" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                <TextBox Name="txtCustomInput" Height="60" TextWrapping="Wrap" Background="#111" Foreground="White" BorderBrush="{DynamicResource ThemeBorder}" BorderThickness="1" Padding="10" FontSize="14" AcceptsReturn="True"/>
                                                <Button Name="btnLaunchCustom" Content="Launch Gemini" Width="200" HorizontalAlignment="Left" Margin="0,15,0,0" Style="{StaticResource ActionBtn}" Background="{DynamicResource ThemeAccent}" Foreground="White" FontWeight="Bold"/>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>

                                    <!-- RIGHT COLUMN -->
                                    <StackPanel Grid.Column="2">
                                        <Border Style="{StaticResource CardStyle}" VerticalAlignment="Top" Padding="20">
                                            <StackPanel>
                                                <TextBlock Text="Enhancements" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                
                                                <TextBlock Text="Aspect Ratio:" Foreground="{DynamicResource ThemeSubText}" FontSize="12" Margin="0,0,0,5"/>
                                                <ComboBox Name="cmbRatio" Height="35" Margin="0,0,0,15"/>
                                                
                                                <CheckBox Name="chk4K" Content="8K Resolution" />
                                                <CheckBox Name="chkReal" Content="Hyper Realistic" />
                                                <CheckBox Name="chkLight" Content="Cinematic Light" />
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </Grid>
                            </StackPanel>

                            <!-- 3. ESSENTIALS -->
                            <StackPanel Name="pnlEssentials" Visibility="Collapsed">
                                 <TextBlock Name="lblEssentials" Text="Essentials" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                 <Border Style="{StaticResource CardStyle}" Padding="25">
                                    <StackPanel>
                                        <TextBlock Text="Chris Titus Tech Toolkit" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}"/>
                                        <TextBlock Text="The ultimate utility for Windows debloating and package management." Foreground="{DynamicResource ThemeSubText}" Margin="0,5,0,20"/>
                                        <Button Name="btnRunCTT" Content="Launch Toolkit" Width="250" HorizontalAlignment="Left" Style="{StaticResource ActionBtn}"/>
                                        <WrapPanel Margin="0,15,0,0">
                                            <Button Name="btnCTTExplain" Content="Read Docs" Width="120" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnCTTWeb" Content="Website" Width="120" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnCTTGit" Content="GitHub" Width="120" Style="{StaticResource ActionBtn}"/>
                                        </WrapPanel>
                                    </StackPanel>
                                 </Border>

                                 <Border Style="{StaticResource CardStyle}" Padding="25" Margin="0,15,0,0">
                                     <StackPanel>
                                          <TextBlock Text=" Office &amp; Activation" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}"/>
                                          <TextBlock Text=" Select version, apps and language to install or manage activation." Foreground="{DynamicResource ThemeSubText}" Margin="0,5,0,15" TextWrapping="Wrap"/>
                                          
                                          <StackPanel Orientation="Horizontal" Margin="0,0,0,15">
                                              <StackPanel Margin="0,0,20,0">
                                                  <TextBlock Text="Version:" Foreground="{DynamicResource ThemeSubText}" FontSize="12" Margin="0,0,0,5"/>
                                                   <ComboBox Name="cmbOfficeVersion" Width="220" Height="30" SelectedIndex="1">
                                                      <ComboBoxItem Content="O365 Business (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="O365 Enterprise (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office ProPlus 2024 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office Standard 2024 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office ProPlus 2021 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office Standard 2021 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office ProPlus 2019 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                      <ComboBoxItem Content="Office Standard 2019 (64-bit Heb)" FlowDirection="LeftToRight"/>
                                                  </ComboBox>
                                              </StackPanel>
                                              <StackPanel Margin="0,0,20,0">
                                                    <StackPanel Orientation="Horizontal" Margin="0,0,0,5">
                                                        <TextBlock Text="Installation Type:" Foreground="{DynamicResource ThemeSubText}" FontSize="12" VerticalAlignment="Center"/>
                                                        <Button Name="btnOfficeInfo" Content="&#xE946;" FontFamily="Segoe MDL2 Assets" Background="Transparent" Foreground="{DynamicResource ThemeAccent}" BorderThickness="0" Margin="5,0,0,0" FontSize="14" Cursor="Hand" ToolTip="Click to see what is included in each version"/>
                                                    </StackPanel>
                                                    <ComboBox Name="cmbOfficeType" Width="260" Height="30" SelectedIndex="0" FlowDirection="LeftToRight" HorizontalContentAlignment="Left">
                                                        <ComboBoxItem Content="Basic (Word, Excel, PowerPoint)"/>
                                                        <ComboBoxItem Content="Full (All Apps)"/>
                                                    </ComboBox>
                                                </StackPanel>
                                          </StackPanel>

                                          <WrapPanel>
                                              <Button Name="btnInstallOffice" Content="Install Office" Width="180" Style="{StaticResource ActionBtn}" Background="#217346" Foreground="White" FontWeight="Bold" Margin="0,0,10,10"/>
                                              <Button Name="btnRunMAS" Width="180" Style="{StaticResource ActionBtn}" Background="#0078D7" Foreground="White" FontWeight="Bold" Margin="0,0,10,10">
                                                  <TextBlock Text="Run Activation (MAS)" FlowDirection="LeftToRight"/>
                                              </Button>
                                              <Button Name="btnRemoveOffice" Content="Remove Office" Width="180" Style="{StaticResource ActionBtn}" Background="#C42B1C" Foreground="White" FontWeight="Bold" Margin="0,0,10,10"/>
                                          </WrapPanel>
                                     </StackPanel>
                                 </Border>
                            </StackPanel>

                                                        <!-- KEYBOARD SHORTCUTS PANEL -->
                            <StackPanel Name="pnlKeyboardShortcuts" Visibility="Collapsed">
                                <TextBlock Name="lblKeyboardShortcutsTitle" Text=" Keyboard Shortcuts" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <ScrollViewer VerticalScrollBarVisibility="Auto" Height="650">
                                    <StackPanel>
                                        <!-- General Windows Shortcuts -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblHdrGeneralWin" Text=" General Windows" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="200"/>
                                                        <ColumnDefinition Width="*"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Grid.RowDefinitions>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                    </Grid.RowDefinitions>
                                                    
                                                    <TextBlock Grid.Row="0" Grid.Column="0" Text="Win + I" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSettings" Grid.Row="0" Grid.Column="1" Text="Open Settings" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="1" Grid.Column="0" Text="Win + X" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdQuickLink" Grid.Row="1" Grid.Column="1" Text="Quick Link Menu" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="2" Grid.Column="0" Text="Win + E" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdExplorer" Grid.Row="2" Grid.Column="1" Text="Open File Explorer" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="3" Grid.Column="0" Text="Win + R" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdRun" Grid.Row="3" Grid.Column="1" Text="Open Run Dialog" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="4" Grid.Column="0" Text="Win + L" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdLock" Grid.Row="4" Grid.Column="1" Text="Lock Computer" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="5" Grid.Column="0" Text="Win + D" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdDesktop" Grid.Row="5" Grid.Column="1" Text="Show/Hide Desktop" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                </Grid>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- Task Manager & System -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblHdrTaskSys" Text=" Task Manager &amp; System" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="200"/>
                                                        <ColumnDefinition Width="*"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Grid.RowDefinitions>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                    </Grid.RowDefinitions>
                                                    
                                                    <TextBlock Grid.Row="0" Grid.Column="0" Text="Ctrl + Shift + Esc" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdTaskMgr" Grid.Row="0" Grid.Column="1" Text="Open Task Manager" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="1" Grid.Column="0" Text="Ctrl + Alt + Del" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSecScreen" Grid.Row="1" Grid.Column="1" Text="Security Options Screen" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="2" Grid.Column="0" Text="Win + Pause" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSysProp" Grid.Row="2" Grid.Column="1" Text="System Properties" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="3" Grid.Column="0" Text="Win + Tab" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdTaskView" Grid.Row="3" Grid.Column="1" Text="Task View (Virtual Desktops)" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                </Grid>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- Window Management -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblHdrWinMgmt" Text=" Window Management" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="200"/>
                                                        <ColumnDefinition Width="*"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Grid.RowDefinitions>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                    </Grid.RowDefinitions>
                                                    
                                                    <TextBlock Grid.Row="0" Grid.Column="0" Text="Win + Arrows" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSnap" Grid.Row="0" Grid.Column="1" Text="Snap Window Left/Right" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="1" Grid.Column="0" Text="Win + Up" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdMax" Grid.Row="1" Grid.Column="1" Text="Maximize Window" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="2" Grid.Column="0" Text="Win + Down" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdMin" Grid.Row="2" Grid.Column="1" Text="Minimize/Restore Window" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="3" Grid.Column="0" Text="Alt + F4" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdClose" Grid.Row="3" Grid.Column="1" Text="Close Active Window" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="4" Grid.Column="0" Text="Alt + Tab" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSwitch" Grid.Row="4" Grid.Column="1" Text="Switch Between Windows" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                </Grid>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- Screenshot & Clipboard -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20">
                                            <StackPanel>
                                                <TextBlock Name="lblHdrClip" Text=" Screenshot &amp; Clipboard" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="200"/>
                                                        <ColumnDefinition Width="*"/>
                                                    </Grid.ColumnDefinitions>
                                                    <Grid.RowDefinitions>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                        <RowDefinition Height="Auto"/>
                                                    </Grid.RowDefinitions>
                                                    
                                                    <TextBlock Grid.Row="0" Grid.Column="0" Text="Win + Shift + S" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdSnip" Grid.Row="0" Grid.Column="1" Text="Snipping Tool (Screenshot)" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="1" Grid.Column="0" Text="PrtScn" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdPrtScn" Grid.Row="1" Grid.Column="1" Text="Screenshot to Clipboard" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="2" Grid.Column="0" Text="Win + V" FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdClipHist" Grid.Row="2" Grid.Column="1" Text="Clipboard History" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                    
                                                    <TextBlock Grid.Row="3" Grid.Column="0" Text="Win + ." FontFamily="Consolas" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,5" FlowDirection="LeftToRight" HorizontalAlignment="Left"/>
                                                    <TextBlock Name="lblKbdEmoji" Grid.Row="3" Grid.Column="1" Text="Emoji Picker" FontSize="14" Foreground="{DynamicResource ThemeSubText}" Margin="0,5"/>
                                                </Grid>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </ScrollViewer>
                            </StackPanel>


                              <!-- 4. WINDOWS TOOLS (FULL) -->
                            <StackPanel Name="pnlWindowsTools" Visibility="Collapsed">
                                <TextBlock Name="lblWinTools" Text="Windows Tools" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                <WrapPanel>
                                    <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                        <StackPanel>
                                            <TextBlock Text="Disk &amp; System" FontSize="16" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnDiskMgmt" Content="Disk Mgmt" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnTaskMgr" Content="Task Manager" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnDevMgmt" Content="Device Mgmt" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnSFC" Content="System File Checker" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnChkdsk" Content="Check Disk" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnDefrag" Content="Optimize Drives" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>
                                    <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                        <StackPanel>
                                            <TextBlock Text="Advanced" FontSize="16" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnRegEdit" Content="Registry Editor" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnGodMode" Content="Create GodMode" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnMsConfig" Content="MsConfig" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnEventVwr" Content="Event Viewer" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnGpEdit" Content="Group Policy" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>
                                    <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                        <StackPanel>
                                            <TextBlock Text="Storage" FontSize="16" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnDiskCleanup" Content="Disk Cleanup" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnTreeSize" Content="TreeSize (Free)" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnCrystalDiskInfo" Content="CrystalDiskInfo" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnCrystalDiskMark" Content="CrystalDiskMark" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>
                                </WrapPanel>
                            </StackPanel>




                            <!-- 9. CLEANUP & MAINTENANCE (RESTORED) -->
                            <StackPanel Name="pnlMaintenance" Visibility="Collapsed">
                                <TextBlock Name="lblCleanupHeader" Text="Cleanup &amp; Maintenance" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <ScrollViewer VerticalScrollBarVisibility="Auto" Height="650">
                                    <StackPanel>
                                        <!-- Quick Actions -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblMaintQuick" Text="Quick Actions" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnCleanAll" Content="One-Click Deep Clean" Width="220" Style="{StaticResource ActionBtn}" Background="#0078D7"/>
                                                    <Button Name="btnEmptyRecycleBin" Content="Empty Recycle Bin" Width="220" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSystemCleanup" Content="Disk Cleanup" Width="220" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- System Temp -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblMaintJunk" Text="System Junk" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnClearTemp" Content="Temp Files" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearUserTemp" Content="User Temp" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearPrefetch" Content="Prefetch" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearWindowsLogs" Content="Windows Logs" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearMemory" Content="Clear Memory RAM" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Browsers -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblMaintBrowser" Text="Browser Cleaning" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnClearEdgeCache" Content="Edge Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearChromeCache" Content="Chrome Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearFirefoxCache" Content="Firefox Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearAllBrowsers" Content="Clean All Browsers" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Windows Update -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text="Windows Update Fixes" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnClearUpdateCache" Content="Update Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearDeliveryOptimization" Content="Delivery Files" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearSoftwareDistribution" Content="SoftwareDist" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnWSUSReset" Content="Reset WSUS" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Network & Cache -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text="Network &amp; Caches" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnClearDNSCache" Content="Flush DNS" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearIconCache" Content="Icon Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearFontCache" Content="Font Cache" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- Privacy -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Name="lblMaintPrivacy" Text="Privacy" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnClearRecentItems" Content="Recent Items" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearJumpLists" Content="Jump Lists" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearRunHistory" Content="Run History" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClearEventLogs" Content="Event Logs" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Storage Tools -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text="Storage Tools" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnStorageSense" Content="Storage Sense" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDefragOptimize" Content="Defrag / Optimize" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnCheckDisk" Content="Check Disk (chkdsk)" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTrim" Content="TRIM SSD" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </ScrollViewer>
                            </StackPanel>

                            <!-- 10. SECURITY CENTER (NEW) -->
                            <StackPanel Name="pnlSecurity" Visibility="Collapsed">
                                <TextBlock Name="lblSecHeader" Text="Security Center" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <ScrollViewer VerticalScrollBarVisibility="Auto" Height="650">
                                    <StackPanel>
                                        <!-- Windows Defender -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" Windows Defender" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnDefOpen" Content="Open Defender" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDefQuickScan" Content=" Quick Scan" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDefFullScan" Content=" Full Scan" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDefUpdate" Content=" Update Signatures" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Network Security -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" Network Security" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnFwAdv" Content=" Firewall Adv" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFwReset" Content="Reset Firewall" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFlushDNS" Content="Flush DNS" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnRenewIP" Content="Renew IP" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- System Hardening -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" System Hardening" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnUAC" Content="UAC Settings" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnUserAccts" Content="User Accounts" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHosts" Content=" Edit Hosts" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPrivacy" Content=" Privacy Settings" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>
                                        
                                        <!-- Tools -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" Tools" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnBitLocker" Content="BitLocker" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTpm" Content="TPM Mgmt" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Forensics & Audit (NEW) -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" Forensics &amp; Audit" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnSecRelMon" Content="Reliability Monitor" Width="160" Style="{StaticResource ActionBtn}" ToolTip="View system stability history"/>
                                                    <Button Name="btnSecResMon" Content="Resource Monitor" Width="160" Style="{StaticResource ActionBtn}" ToolTip="Detailed performance tracking"/>
                                                    <Button Name="btnSecMrt" Content="Virus Removal (MRT)" Width="160" Style="{StaticResource ActionBtn}" ToolTip="Microsoft Malicious Software Removal Tool"/>
                                                    <Button Name="btnSecEventLogs" Content="Security Logs" Width="160" Style="{StaticResource ActionBtn}" ToolTip="View Windows Security Events"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>

                                        <!-- Policies & Access (NEW) -->
                                        <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,15">
                                            <StackPanel>
                                                <TextBlock Text=" Policies &amp; Access" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                                <WrapPanel>
                                                    <Button Name="btnSecLocalPol" Content="Local Security Policy" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSecCertMgr" Content="Certificates" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSecCredMgr" Content="Credentials" Width="160" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSecNetPlWiz" Content="Adv User Mgmt" Width="160" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </ScrollViewer>
                            </StackPanel>

                            <!-- 5. MUSIC MACHINE (RESTORED SIMPLE UI + ADVANCED) -->
                            <StackPanel Name="pnlMusic" Visibility="Collapsed">
                                <StackPanel Orientation="Horizontal" Margin="0,0,0,20" VerticalAlignment="Center">
                                    <TextBlock Name="lblMusicHeader" Text="Music Hub" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}"/>
                                    <!-- This button toggles visible panel -->
                                    <Button Name="btnGoToAdvanced" Content="Switch to Advanced Mode " Margin="50,0,0,0" Width="220" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnBackToSimple" Content=" Back to Simple" Margin="50,0,0,0" Width="180" Visibility="Collapsed" Style="{StaticResource ActionBtn}"/>
                                </StackPanel>

                                <!-- SIMPLE MODE (VISIBLE BY DEFAULT) -->
                                <StackPanel Name="pnlMusicSimple">
                                    <Border Style="{StaticResource CardStyle}" Padding="25">
                                        <StackPanel>
                                            <TextBlock Text="Quick Mix Select" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <TextBlock Text="Select a genre to play a random YouTube mix:" Foreground="{DynamicResource ThemeSubText}" Margin="0,0,0,10"/>
                                            <ComboBox Name="cmbMusicGenre" Height="40" FontSize="16" Margin="0,0,0,20"/>
                                            <Button Name="btnPlayMusic" Content=" Play Random Mix" Height="50" Background="#1DB954" Foreground="White" FontWeight="Bold" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>
                                    <TextBlock Name="txtStatusSimple" Text="Ready to play." Foreground="{DynamicResource ThemeSubText}" HorizontalAlignment="Center" Margin="0,20,0,0"/>
                                </StackPanel>

                                <!-- ADVANCED MODE (HIDDEN BY DEFAULT) -->
                                <StackPanel Name="pnlMusicAdvanced" Visibility="Collapsed">
                                    <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                        <Button Name="btnSurprise" Content=" Surprise Me" Width="150" Height="40" Background="{DynamicResource ThemeAccent}" Style="{StaticResource ActionBtn}"/>
                                    </StackPanel>
                                    
                                    <TextBlock Name="txtStatusAdv" Text="Select a category to play a random video mix." Foreground="{DynamicResource ThemeSubText}" Margin="0,0,0,10"/>

                                    <!-- Name "tabCtrlMusic" used for Global View Toggle Logic -->
                                    <TabControl Name="tabCtrlMusic" Background="Transparent" BorderThickness="0" Margin="0">
                                        
                                        <!-- Tab: Israeli -->
                                        <TabItem Name="tabIsr" Header="Israeli">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnIsrGeneral" Content=" General Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrRock" Content=" Rock Classics" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrPopRock" Content=" Pop/Rock Icons" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMizrahi" Content=" Mizrahi New" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMizrahiRetro" Content=" Mizrahi Retro" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMizrahiDiach" Content=" Dikaon/Sad" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnOldIsraeli" Content=" Eretz Yisrael" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnKaveret" Content=" Kaveret &amp; Co" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrHipHop" Content=" HipHop &amp; Rap" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrIndie" Content=" Indie Scene" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrAlt" Content=" Alternative" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnArmy" Content=" Army Bands" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrKids" Content=" Kids Classics" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIsrEuro" Content=" Euro-Israel" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Rock & Metal -->
                                        <TabItem Name="tabRock" Header="Rock &amp; Metal">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnClassicRock" Content=" Classic Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAltRock" Content=" Alternative 90s" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIndieRock" Content=" Indie Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBritpop" Content=" Britpop" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHardRock" Content=" Hard Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPunk" Content=" Punk Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPopPunk" Content=" Pop Punk" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEmo" Content=" Emo Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPostRock" Content=" Post Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNuMetal" Content=" Nu-Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIndustrial" Content=" Industrial" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSoftRock" Content=" Soft Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnProg" Content=" Prog Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnGrunge" Content=" Grunge" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHeavyMetal" Content=" Heavy Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnThrashMetal" Content=" Thrash Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMetalCore" Content=" Metalcore" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSymphonic" Content=" Symphonic Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFolkMetal" Content=" Folk Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHairMetal" Content=" Hair Metal" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Pop -->
                                        <TabItem Name="tabPop" Header="Pop">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnPop80s" Content=" 80s Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPop90s" Content=" 90s Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPop2000s" Content=" 2000s Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPop2010s" Content=" 2010s Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPopModern" Content=" Modern Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIndiePop" Content=" Indie Pop" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDisco" Content=" Disco 70s" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnLatinPop" Content=" Latin Pop" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBoyBands" Content=" Boy Bands" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnGirlGroups" Content=" Girl Groups" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEurovision" Content=" Eurovision" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Jazz, Blues & Soul -->
                                        <TabItem Name="tabJazz" Header="Jazz/Soul">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnJazz" Content=" Jazz Classics" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBebop" Content=" Bebop" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSmooth" Content=" Smooth Jazz" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFusion" Content=" Jazz Fusion" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBlues" Content=" Blues Legends" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBluesRock" Content=" Blues Rock" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSoul" Content=" Classic Soul" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNeoSoul" Content=" Neo Soul" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnCountry" Content=" Country Classic" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnCountryMod" Content=" Country Modern" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFolk" Content=" Folk" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Classics & OST -->
                                        <TabItem Name="tabOst" Header="OST &amp; Classic">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnClassicalEpic" Content=" Classical Epic" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnClassicalRelax" Content=" Classical Relax" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnOST" Content=" Movie OST" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDisney" Content=" Disney Hits" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnGaming" Content=" Gaming OST" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAnime" Content=" Anime OST" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMusicals" Content=" Musicals" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPiano" Content=" Relaxing Piano" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Electronic -->
                                        <TabItem Name="tabElec" Header="Electronic">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnHouse" Content=" House Classic" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDeepHouse" Content=" Deep House" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTechno" Content=" Techno" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEDM" Content=" Mainstream EDM" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTrance" Content=" Uplifting Trance" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPsy" Content=" Psy-Trance" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSynth" Content=" Synthwave" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDubstep" Content=" Dubstep" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHardstyle" Content=" Hardstyle" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDnB" Content=" DnB &amp; Jungle" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAmbient" Content=" Ambient" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnFutureBass" Content=" Future Bass" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnLofi" Content=" Lofi &amp; Chill" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                         <!-- Tab: Hip Hop & World -->
                                        <TabItem Name="tabWorld" Header="World/Urban">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <Button Name="btnOldHipHop" Content=" Old School Rap" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNewHipHop" Content=" Modern Rap" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTrap" Content=" Trap" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnJazzRap" Content=" Jazz Rap" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnReggae" Content=" Reggae" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnLatin" Content=" Reggaeton" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnKpop" Content=" K-Pop" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAfro" Content=" Afrobeats" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBossa" Content=" Bossa Nova" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnCeltic" Content=" Celtic/Irish" Width="180" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBalkan" Content=" Balkan Beats" Width="180" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                         <!-- Tab: Artists -->
                                        <TabItem Name="tabArtists" Header="Artists">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                    <!-- International -->
                                                    <TextBlock Text="International Stars" Foreground="{DynamicResource ThemeAccent}" Width="1000" Margin="10,0,0,5" FontWeight="Bold" FontSize="18"/>
                                                    
                                                    <Button Name="btnQueen" Content="Queen" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBeatles" Content="The Beatles" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnWeeknd" Content="The Weeknd" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTaylor" Content="Taylor Swift" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEminem" Content="Eminem" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnColdplay" Content="Coldplay" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBeyonce" Content="Beyonce" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnRihanna" Content="Rihanna" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnJustinB" Content="Justin Bieber" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEdSheeran" Content="Ed Sheeran" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBruno" Content="Bruno Mars" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAdele" Content="Adele" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAriana" Content="Ariana Grande" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDuaLipa" Content="Dua Lipa" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnDrake" Content="Drake" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnKendrick" Content="Kendrick Lamar" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnGaga" Content="Lady Gaga" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnKaty" Content="Katy Perry" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnImagine" Content="Imagine Dragons" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMaroon5" Content="Maroon 5" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMJ" Content="Michael Jackson" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnElvis" Content="Elvis Presley" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBowie" Content="David Bowie" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnElton" Content="Elton John" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPinkFloyd" Content="Pink Floyd" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnLedZep" Content="Led Zeppelin" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnLinkin" Content="Linkin Park" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHarry" Content="Harry Styles" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnBillie" Content="Billie Eilish" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMiley" Content="Miley Cyrus" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAvicii" Content="Avicii" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNirvana" Content="Nirvana" Width="140" Style="{StaticResource ActionBtn}"/>

                                                    <!-- Israeli -->
                                                    <TextBlock Text="Israeli Stars" Foreground="{DynamicResource ThemeAccent}" Width="1000" Margin="10,20,0,5" FontWeight="Bold" FontSize="18"/>
                                                    
                                                    <Button Name="btnOmer" Content="Omer Adam" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnShlomo" Content="Shlomo Artzi" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnArik" Content="Arik Einstein" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnTuna" Content="Tuna" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnRavid" Content="Ravid Plotnik" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEdenH" Content="Eden Hason" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnOsher" Content="Osher Cohen" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHanan" Content="Hanan Ben Ari" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNoa" Content="Noa Kirel" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEyal" Content="Eyal Golan" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSarit" Content="Sarit Hadad" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnPeer" Content="Peer Tasi" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnYasmin" Content="Yasmin Moallem" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIdan" Content="Idan Raichel" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnAviv" Content="Aviv Geffen" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIvri" Content="Ivri Lider" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnStatic" Content="Static" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnShalom" Content="Shalom Hanoch" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnYehudit" Content="Yehudit Ravitz" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEthnix" Content="Ethnix" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnYehudim" Content="HaYehudim" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnEdenBZ" Content="Eden Ben Zaken" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnIshay" Content="Ishay Ribo" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnNathan" Content="Nathan Goshen" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMiri" Content="Miri Mesika" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnMoshe" Content="Moshe Peretz" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnHadag" Content="HaDag Nahash" Width="140" Style="{StaticResource ActionBtn}"/>
                                                    <Button Name="btnSub" Content="Subliminal" Width="140" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>

                                        <!-- Tab: Moods -->
                                        <TabItem Name="tabMoods" Header="Moods">
                                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                                <WrapPanel Margin="10">
                                                     <Button Name="btnWorkout" Content=" Workout / Energy" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnParty" Content=" Party" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnFocus" Content=" Deep Focus" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnCoffee" Content=" Coffee Shop" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnRain" Content=" Rain Sounds" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnNature" Content=" Nature Sounds" Width="200" Style="{StaticResource ActionBtn}"/>
                                                     <Button Name="btnGamingMood" Content=" Gaming Mode" Width="200" Style="{StaticResource ActionBtn}"/>
                                                </WrapPanel>
                                            </ScrollViewer>
                                        </TabItem>
                                    </TabControl>
                                </StackPanel>
                            </StackPanel>

                            <!-- 10. SYSTEM INFO (IMPROVED & NATIVE) -->
                            <StackPanel Name="pnlSysInfoTools" Visibility="Collapsed">
                                 <TextBlock Name="lblHwHeader" Text="Hardware Tools" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                 
                                 <Grid Margin="0,0,0,20">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="1*"/>
                                        <ColumnDefinition Width="1*"/>
                                        <ColumnDefinition Width="1*"/>
                                    </Grid.ColumnDefinitions>
                                    <Grid.RowDefinitions>
                                        <RowDefinition Height="Auto"/>
                                        <RowDefinition Height="Auto"/>
                                    </Grid.RowDefinitions>

                                    <!-- CPU Card -->
                                    <Border Grid.Column="0" Grid.Row="0" Style="{StaticResource CardStyle}" Padding="15" Margin="5">
                                        <StackPanel>
                                            <TextBlock Text="CPU (Processor)" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" FontSize="16" Margin="0,0,0,10"/>
                                            <TextBlock Name="txtHwCPU" Text="Loading..." Foreground="{DynamicResource ThemeFg}" FontSize="14" TextWrapping="Wrap"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- RAM Card -->
                                    <Border Grid.Column="1" Grid.Row="0" Style="{StaticResource CardStyle}" Padding="15" Margin="5">
                                        <StackPanel>
                                            <TextBlock Text="RAM (Memory)" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" FontSize="16" Margin="0,0,0,10"/>
                                            <TextBlock Name="txtHwRAM" Text="Loading..." Foreground="{DynamicResource ThemeFg}" FontSize="14" TextWrapping="Wrap"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- GPU Card -->
                                    <Border Grid.Column="2" Grid.Row="0" Style="{StaticResource CardStyle}" Padding="15" Margin="5">
                                        <StackPanel>
                                            <TextBlock Text="GPU (Graphics)" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" FontSize="16" Margin="0,0,0,10"/>
                                            <TextBlock Name="txtHwGPU" Text="Loading..." Foreground="{DynamicResource ThemeFg}" FontSize="14" TextWrapping="Wrap"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- Disk Card -->
                                    <Border Grid.Column="0" Grid.Row="1" Style="{StaticResource CardStyle}" Padding="15" Margin="5">
                                        <StackPanel>
                                            <TextBlock Text="Storage (Disks)" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" FontSize="16" Margin="0,0,0,10"/>
                                            <TextBlock Name="txtHwDisk" Text="Loading..." Foreground="{DynamicResource ThemeFg}" FontSize="14" TextWrapping="Wrap"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- BIOS Card -->
                                    <Border Grid.Column="1" Grid.Row="1" Style="{StaticResource CardStyle}" Padding="15" Margin="5">
                                        <StackPanel>
                                            <TextBlock Text="BIOS / Motherboard" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" FontSize="16" Margin="0,0,0,10"/>
                                            <TextBlock Name="txtHwBio" Text="Loading..." Foreground="{DynamicResource ThemeFg}" FontSize="14" TextWrapping="Wrap"/>
                                        </StackPanel>
                                    </Border>
                                 </Grid>

                                 <TextBlock Name="lblExtTools" Text="System Utilities (Built-in)" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource ThemeSubText}" Margin="0,10,0,10"/>
                                 <WrapPanel>
                                     <Button Name="btnResMon" Content="Resource Monitor" Width="180" Style="{StaticResource ActionBtn}" ToolTip="View real-time CPU, Disk, Network &amp; Memory usage."/>
                                     <Button Name="btnMsInfo" Content="System Info (MsInfo32)" Width="180" Style="{StaticResource ActionBtn}" ToolTip="Detailed system information."/>
                                     <Button Name="btnDxDiag" Content="DirectX Diag" Width="180" Style="{StaticResource ActionBtn}" ToolTip="Video and Sound diagnostics."/>
                                     <Button Name="btnExportHw" Content=" Export Report" Width="180" Style="{StaticResource ActionBtn}" ToolTip="Generate a text file report on Desktop."/>
                                 </WrapPanel>
                            </StackPanel>



                            <!-- 12. TWEAKS & THEMES (MERGED) -->
                             <StackPanel Name="pnlTweaks" Visibility="Collapsed">
                                 <TextBlock Name="lblTweakHeader" Text="Tweaks &amp; Themes" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                 
                                 <WrapPanel>
                                     <!-- Group 0: Theme Presets (NEW) -->
                                     <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                         <StackPanel>
                                             <TextBlock Text=" Theme Presets" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                             <Button Name="btnThemeOriginal" Content="Original Dark" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnThemeTokyo" Content=" Tokyo Night" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnThemeCyber" Content=" Cyberpunk" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnThemeForest" Content=" Forest" Style="{StaticResource ActionBtn}"/>
                                                                                           <Button Name="btnThemeNordic" Content=" Nordic" Style="{StaticResource ActionBtn}"/>
                                              <Button Name="btnThemeMario" Content=" Super Mario" Style="{StaticResource ActionBtn}"/>
                                              <Button Name="btnThemePS2" Content=" PlayStation 2" Style="{StaticResource ActionBtn}"/>
                                              <Button Name="btnCustomBg" Content=" Custom Background" Style="{StaticResource ActionBtn}"/>
                                          </StackPanel>
                                     </Border>
                                     <!-- Group 1: Taskbar & Start Menu -->
                                     <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                         <StackPanel>
                                             <TextBlock Name="lblTweakTaskbar" Text="Taskbar &amp; Start Menu" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                             <Button Name="btnApplyTaskbar" Content="Toggle Center/Left Align" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnSecondsClock" Content="Toggle Seconds in Clock" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnDisableBing" Content="Disable Bing Search" Style="{StaticResource ActionBtn}"/>
                                         </StackPanel>
                                     </Border>

                                     <!-- Group 2: Explorer -->
                                     <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                         <StackPanel>
                                             <TextBlock Name="lblTweakExplorer" Text="File Explorer" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                             <Button Name="btnClassicContext" Content="Classic Context Menu" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnFileExt" Content="Show/Hide File Ext" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnHiddenFiles" Content="Show/Hide Hidden Files" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnCompactMode" Content="Toggle Compact Mode" Style="{StaticResource ActionBtn}"/>
                                         </StackPanel>
                                     </Border>

                                     <!-- Group 3: System -->
                                     <Border Style="{StaticResource CardStyle}" Width="350" Margin="5" Padding="25">
                                         <StackPanel>
                                             <TextBlock Name="lblTweakSystem" Text="System &amp; Visuals" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                             <Button Name="btnDarkMode" Content="Toggle Dark/Light Mode" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnGameMode" Content="Enable Game Mode" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnMouseAccel" Content="Disable Mouse Accel" Style="{StaticResource ActionBtn}"/>
                                             <Button Name="btnIconSettings" Content="Desktop Icon Settings" Style="{StaticResource ActionBtn}"/>
                                         </StackPanel>
                                     </Border>
                                 </WrapPanel>
                            </StackPanel>
                            
                            <!-- 13. USER MANAGEMENT (RESTORED FULL) -->
                            <StackPanel Name="pnlUserMgmt" Visibility="Collapsed">
                                <TextBlock Name="lblUserHeader" Text="User Management" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="2*"/>   <!-- User List -->
                                        <ColumnDefinition Width="20"/>   <!-- Spacer -->
                                        <ColumnDefinition Width="1*"/>   <!-- Actions -->
                                    </Grid.ColumnDefinitions>

                                    <!-- User List -->
                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}" Padding="15">
                                        <DockPanel>
                                            <TextBlock Name="lblLocalUsers" Text="Local Users" DockPanel.Dock="Top" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <ListView Name="lstUsers" Background="Transparent" BorderThickness="0" Foreground="{DynamicResource ThemeFg}" FontSize="14">
                                                <ListView.View>
                                                    <GridView>
                                                        <GridViewColumn Header="Username" Width="150" DisplayMemberBinding="{Binding Name}"/>
                                                        <GridViewColumn Header="Enabled" Width="80" DisplayMemberBinding="{Binding Enabled}"/>
                                                        <GridViewColumn Header="Admin" Width="80" DisplayMemberBinding="{Binding IsAdmin}"/>
                                                        <GridViewColumn Header="Description" Width="200" DisplayMemberBinding="{Binding Description}"/>
                                                    </GridView>
                                                </ListView.View>
                                            </ListView>
                                        </DockPanel>
                                    </Border>

                                    <!-- Actions Panel -->
                                    <StackPanel Grid.Column="2">
                                        <Border Style="{StaticResource CardStyle}" Padding="15">
                                            <StackPanel>
                                                <TextBlock Name="lblUserActions" Text="User Actions" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                
                                                <Button Name="btnRefreshUsers" Content=" Refresh List" Style="{StaticResource ActionBtn}"/>
                                                <Button Name="btnCreateUser" Content=" Create New User" Style="{StaticResource ActionBtn}"/>
                                                
                                                <TextBlock Text="Selected User:" Foreground="{DynamicResource ThemeSubText}" Margin="0,15,0,5"/>
                                                <Button Name="btnResetPass" Content=" Reset Password" Style="{StaticResource ActionBtn}"/>
                                                <Button Name="btnToggleActive" Content=" Enable/Disable" Style="{StaticResource ActionBtn}"/>
                                                <Button Name="btnToggleAdmin" Content=" Toggle Admin" Style="{StaticResource ActionBtn}"/>
                                                <Button Name="btnDeleteUser" Content=" Delete User" Background="#AA0000" Style="{StaticResource ActionBtn}"/>
                                            </StackPanel>
                                        </Border>

                                        <Border Style="{StaticResource CardStyle}" Padding="15">
                                            <StackPanel>
                                                <TextBlock Name="lblAdvTools" Text="Advanced Tools" FontSize="18" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                                <Button Name="btnNetplwiz" Content="Netplwiz (Auto Login)" Style="{StaticResource ActionBtn}"/>
                                                <Button Name="btnLusrmgr" Content="Lusrmgr.msc" Style="{StaticResource ActionBtn}"/>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </Grid>
                            </StackPanel>
                            <!-- GAMING CENTER PANEL -->
                            <StackPanel Name="pnlGaming" Visibility="Collapsed">
                                <TextBlock Text="Gaming Center" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,4"/>
                                <TextBlock Text="Scan, launch and optimize your games" FontSize="13" Foreground="{DynamicResource ThemeSubText}" Margin="0,0,0,18"/>

                                <!-- Stats + Scan -->
                                <Border Style="{StaticResource CardStyle}" Margin="0,0,0,12">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>
                                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                            <TextBlock Name="lblGGameCount" Text="0 games" FontSize="22" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,12,0"/>
                                            <TextBlock Name="lblGLastScan" Text="Not scanned yet" FontSize="12" Foreground="{DynamicResource ThemeSubText}" VerticalAlignment="Bottom" Margin="0,0,0,3"/>
                                        </StackPanel>
                                        <Button Grid.Column="1" Name="btnGScan" Content="Scan My PC" Style="{StaticResource ActionBtn}" Width="130" Height="36" Margin="0,0,8,0"/>
                                        <Button Grid.Column="2" Name="btnGRescan" Content="Rescan" Style="{StaticResource ActionBtn}" Width="80" Height="36"/>
                                    </Grid>
                                </Border>

                                <!-- Launchers -->
                                <Border Style="{StaticResource CardStyle}" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="Game Launchers" FontSize="14" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnGSteam"     Content="Steam"      Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGEpic"      Content="Epic"       Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGGOG"       Content="GOG"        Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGEA"        Content="EA App"     Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGUbisoft"   Content="Ubisoft"    Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGBattleNet" Content="Battle.net" Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnGXbox"      Content="Xbox"       Style="{StaticResource ActionBtn}" Width="110" Height="34" Margin="0,0,6,6"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Margin="0,0,0,12">
                                    <StackPanel>
                                        <TextBlock Text="Quick Desktop Themes" FontSize="14" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnThemeXP" Content="Windows XP Bliss" Style="{StaticResource ActionBtn}" Width="150" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnThemeVista7" Content="Windows 7 Aero" Style="{StaticResource ActionBtn}" Width="150" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnThemeXboxOG" Content="Xbox Original" Style="{StaticResource ActionBtn}" Width="150" Height="34" Margin="0,0,6,6"/>
                                            <Button Name="btnThemeXbox360" Content="Xbox 360" Style="{StaticResource ActionBtn}" Width="150" Height="34" Margin="0,0,6,6"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                                <!-- Game Library + Side -->
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="2*"/>
                                        <ColumnDefinition Width="10"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>

                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}">
                                        <StackPanel>
                                            <Grid Margin="0,0,0,10">
                                                <TextBlock Text="Game Library" FontSize="14" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" HorizontalAlignment="Left" VerticalAlignment="Center"/>
                                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                                    <Button Name="btnGAddManual" Content="+ Add Game" Style="{StaticResource ActionBtn}" Width="90" Height="28" Margin="0,0,5,0"/>
                                                    <Button Name="btnGLaunch" Content="Launch" Style="{StaticResource ActionBtn}" Width="90" Height="28"/>
                                                </StackPanel>
                                            </Grid>
                                            <Grid Margin="0,0,0,8">
                                                <Grid.ColumnDefinitions>
                                                    <ColumnDefinition Width="*"/>
                                                    <ColumnDefinition Width="120"/>
                                                </Grid.ColumnDefinitions>
                                                <TextBox Name="txtGSearch" Grid.Column="0" Background="#0d1b2e" Foreground="{DynamicResource ThemeFg}" BorderBrush="#334" BorderThickness="1" Padding="8,4" FontSize="12" Margin="0,0,6,0" Height="30" VerticalContentAlignment="Center"/>
                                                <ComboBox Name="cmbGFilter" Grid.Column="1" Background="#0d1b2e" Foreground="{DynamicResource ThemeFg}" BorderBrush="#334" Height="30" FontSize="11">
                                                    <ComboBoxItem Content="All" IsSelected="True"/>
                                                    <ComboBoxItem Content="Steam"/>
                                                    <ComboBoxItem Content="Epic"/>
                                                    <ComboBoxItem Content="GOG"/>
                                                    <ComboBoxItem Content="EA"/>
                                                    <ComboBoxItem Content="Ubisoft"/>
                                                    <ComboBoxItem Content="Xbox/MS"/>
                                                </ComboBox>
                                            </Grid>
                                            <ScrollViewer Height="280" VerticalScrollBarVisibility="Auto">
                                                <ListView Name="lstGGames" Background="Transparent" BorderThickness="0" SelectionMode="Single">
                                                    <ListView.ItemContainerStyle>
                                                        <Style TargetType="ListViewItem">
                                                            <Setter Property="Background" Value="Transparent"/>
                                                            <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
                                                            <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
                                                            <Setter Property="Padding" Value="0"/>
                                                            <Setter Property="Margin" Value="0,1"/>
                                                            <Style.Triggers>
                                                                <Trigger Property="IsSelected" Value="True"><Setter Property="Background" Value="#1e3a5f"/></Trigger>
                                                                <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1a2c3d"/></Trigger>
                                                            </Style.Triggers>
                                                        </Style>
                                                    </ListView.ItemContainerStyle>
                                                    <ListView.ItemTemplate>
                                                        <DataTemplate>
                                                            <Grid Height="34" Margin="4,0">
                                                                <Grid.ColumnDefinitions>
                                                                    <ColumnDefinition Width="28"/>
                                                                    <ColumnDefinition Width="*"/>
                                                                    <ColumnDefinition Width="72"/>
                                                                    <ColumnDefinition Width="160"/>
                                                                </Grid.ColumnDefinitions>
                                                                <Image Grid.Column="0" Source="{Binding Icon}" Width="22" Height="22" VerticalAlignment="Center" RenderOptions.BitmapScalingMode="HighQuality"/>
                                                                <TextBlock Grid.Column="1" Text="{Binding Name}" VerticalAlignment="Center" FontSize="12" Margin="6,0,0,0" TextTrimming="CharacterEllipsis"/>
                                                                <Border Grid.Column="2" CornerRadius="4" Background="{Binding PlatformBrush}" Margin="4,7" Opacity="0.9">
                                                                    <TextBlock Text="{Binding Platform}" FontSize="10" FontWeight="Bold" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center" Padding="3,1"/>
                                                                </Border>
                                                                <TextBlock Grid.Column="3" Text="{Binding ExePath}" VerticalAlignment="Center" FontSize="10" Foreground="#5a7090" TextTrimming="CharacterEllipsis"/>
                                                            </Grid>
                                                        </DataTemplate>
                                                    </ListView.ItemTemplate>
                                                </ListView>
                                            </ScrollViewer>
                                        </StackPanel>
                                    </Border>

                                    <!-- GPU + Optimize -->
                                    <StackPanel Grid.Column="2">
                                        <Border Style="{StaticResource CardStyle}" Margin="0,0,0,10">
                                            <StackPanel>
                                                <TextBlock Text="GPU Software" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,8"/>
                                                <Button Name="btnGNvidiaCP"  Content="NVIDIA Control Panel" Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGGeForce"   Content="GeForce Experience"   Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGAMD"       Content="AMD Radeon"           Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGIntelArc"  Content="Intel Arc"            Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGMSIAB"     Content="MSI Afterburner"      Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch"/>
                                            </StackPanel>
                                        </Border>
                                        <Border Style="{StaticResource CardStyle}">
                                            <StackPanel>
                                                <TextBlock Text="Optimization" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,8"/>
                                                <Button Name="btnGGameMode"   Content="Enable Game Mode"     Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGMaxPerf"    Content="Max Performance"      Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGNoXbox"     Content="Disable Xbox Bar"     Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGKillBG"     Content="Kill Background"      Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGFlushRAM"   Content="Flush RAM"            Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch" Margin="0,0,0,4"/>
                                                <Button Name="btnGHAGS"       Content="Enable HAGS"          Style="{StaticResource ActionBtn}" HorizontalAlignment="Stretch"/>
                                            </StackPanel>
                                        </Border>
                                    </StackPanel>
                                </Grid>
                            </StackPanel>


                            <!-- 14. BEAST CONTROL CENTER (INTEGRATED) -->
                            <StackPanel Name="pnlBeast" Visibility="Collapsed">
                                <TextBlock Name="lblBeastHeader" Text="System Health Center" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <!-- Output Log Area -->
                                <Border Style="{StaticResource CardStyle}" Padding="15" Margin="0,0,0,20">
                                    <StackPanel>
                                        <Grid Margin="0,0,0,10">
                                            <TextBlock Name="lblBeastLog" Text=" Activity Log" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" HorizontalAlignment="Left"/>
                                            <Button Name="btnClearBeastLog" Content=" Clear" Width="80" Height="25" Style="{StaticResource ActionBtn}" HorizontalAlignment="Right"/>
                                        </Grid>
                                        <ScrollViewer Height="150" VerticalScrollBarVisibility="Auto">
                                            <TextBlock Name="txtBeastLog" TextWrapping="Wrap" Foreground="#00FF00" Background="#050505" Padding="10" FontFamily="Consolas" FontSize="11"/>
                                        </ScrollViewer>
                                    </StackPanel>
                                </Border>

                                <!-- 4-Column Layout for Groups -->
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="10"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="10"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="10"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>

                                    <!-- MAINTENANCE GROUP -->
                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblBeastMaint" Text="Maintenance &amp; Repair" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnBeastGlobalRepair" Content="Full Repair (SFC/DISM)" Style="{StaticResource ActionBtn}" Background="DarkRed"/>
                                            <Button Name="btnBeastCleanTemp" Content="Clean Temp Files" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastEmptyRecycle" Content="Empty Recycle Bin" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastResetStore" Content="Reset Windows Store" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastIconCache" Content="Reset Icon Cache" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastWinUpdate" Content="Clean Update Cache" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- HARDWARE GROUP -->
                                    <Border Grid.Column="2" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblBeastHard" Text="Hardware &amp; Performance" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnBeastStress" Content="Stress Test (WinSAT)" Style="{StaticResource ActionBtn}" Background="DarkOrange"/>
                                            <Button Name="btnBeastRAM" Content="Check RAM &amp; Slots" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastSMART" Content="Disk Health (SMART)" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastCPU" Content="CPU Details" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastBattery" Content="Battery Report (HTML)" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastHighPerf" Content="Max Performance" Style="{StaticResource ActionBtn}" Background="Gold" Foreground="Black"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- NETWORK GROUP -->
                                    <Border Grid.Column="4" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblBeastNet" Text="Network &amp; Communication" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnBeastNetReset" Content="Reset Network &amp; IP" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastDNS" Content="Flush DNS Cache" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastPorts" Content="Scan Open Ports" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastPublicIP" Content="Show Public IP" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastWiFi" Content="Wi-Fi Profiles List" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastPing" Content="Ping Test (Google)" Style="{StaticResource ActionBtn}"/>
                                        </StackPanel>
                                    </Border>

                                    <!-- SECURITY & SYSTEM GROUP -->
                                    <Border Grid.Column="6" Style="{StaticResource CardStyle}" Padding="15">
                                        <StackPanel>
                                            <TextBlock Name="lblBeastSec" Text="Security &amp; System" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnBeastProductKey" Content="Extract Product Key" Style="{StaticResource ActionBtn}" Background="Gold" Foreground="Black"/>
                                            <Button Name="btnBeastRestorePoint" Content="Create Restore Point" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastTopRAM" Content="Top RAM Processes" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastStartup" Content="Startup Programs" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastUptime" Content="System Uptime" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastEventLog" Content="Clear Event Logs" Style="{StaticResource ActionBtn}" Background="SaddleBrown"/>
                                        </StackPanel>
                                    </Border>
                                </Grid>

                                <!-- Quick Tools Bar -->
                                <Border Style="{StaticResource CardStyle}" Padding="15" Margin="0,10,0,0">
                                    <StackPanel>
                                        <TextBlock Name="lblBeastQuickTools" Text="Quick Access Tools" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button Name="btnBeastTaskMgr" Content="Task Manager" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastDevMgr" Content="Device Manager" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastDiskMgr" Content="Disk Management" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastRegEdit" Content="Registry Editor" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnBeastNetplwiz" Content="User Management" Width="180" Style="{StaticResource ActionBtn}"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- 15. UPDATE MANAGER (NEW) -->
                            <StackPanel Name="pnlUpdateMgr" Visibility="Collapsed">
                                <TextBlock Name="lblUpdateMgrHeader" Text="Update Manager" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,20"/>
                                
                                <!-- Update History Section -->
                                <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,20">
                                    <StackPanel>
                                        <Grid Margin="0,0,0,15">
                                            <TextBlock Text=" Update History (Last 10)" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" HorizontalAlignment="Left"/>
                                            <Button Name="btnRefreshHistory" Content=" Refresh" Width="100" Height="30" Style="{StaticResource ActionBtn}" HorizontalAlignment="Right"/>
                                        </Grid>
                                        
                                        <ListBox Name="lstUpdateHistory" Height="200" Background="#0A0A0A" BorderThickness="1" BorderBrush="{DynamicResource ThemeBorder}" Foreground="{DynamicResource ThemeFg}" FontSize="12" FontFamily="Consolas" Padding="5">
                                            <ListBox.ItemContainerStyle>
                                                <Style TargetType="ListBoxItem">
                                                    <Setter Property="Background" Value="Transparent"/>
                                                    <Setter Property="Foreground" Value="{DynamicResource ThemeFg}"/>
                                                    <Setter Property="Padding" Value="8"/>
                                                    <Setter Property="Margin" Value="0,2"/>
                                                    <Style.Triggers>
                                                        <Trigger Property="IsMouseOver" Value="True">
                                                            <Setter Property="Background" Value="#22888888"/>
                                                        </Trigger>
                                                        <Trigger Property="IsSelected" Value="True">
                                                            <Setter Property="Background" Value="{DynamicResource ThemeAccent}"/>
                                                            <Setter Property="Foreground" Value="White"/>
                                                        </Trigger>
                                                    </Style.Triggers>
                                                </Style>
                                            </ListBox.ItemContainerStyle>
                                        </ListBox>
                                        
                                        <Grid Margin="0,15,0,0">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="*"/>
                                                <ColumnDefinition Width="10"/>
                                                <ColumnDefinition Width="Auto"/>
                                            </Grid.ColumnDefinitions>
                                            
                                            <TextBox Name="txtKBID" Grid.Column="0" Height="35" VerticalContentAlignment="Center" Padding="10" FontSize="14" Background="{DynamicResource ThemeCardBg}" Foreground="{DynamicResource ThemeFg}" BorderBrush="{DynamicResource ThemeBorder}" ToolTip="Enter KB ID (e.g., KB5012345)"/>
                                            
                                            <StackPanel Grid.Column="2" Orientation="Horizontal">
                                                <Button Name="btnAnalyzeUpdate" Content=" Analyze" Width="120" Height="35" Style="{StaticResource ActionBtn}" Margin="0,0,10,0"/>
                                                <Button Name="btnUninstallUpdate" Content=" Uninstall" Width="120" Height="35" Style="{StaticResource ActionBtn}" Background="DarkRed"/>
                                            </StackPanel>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                                
                                <!-- Analysis Output -->
                                <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,0,0,20">
                                    <StackPanel>
                                        <TextBlock Text=" Analysis Report" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                        <ScrollViewer Height="150" VerticalScrollBarVisibility="Auto">
                                            <TextBlock Name="txtAnalysisReport" TextWrapping="Wrap" Foreground="{DynamicResource ThemeFg}" Background="#0A0A0A" Padding="10" FontFamily="Consolas" FontSize="11" Text="No analysis performed yet. Enter a KB ID and click Analyze."/>
                                        </ScrollViewer>
                                    </StackPanel>
                                </Border>
                                
                                <!-- Check for Updates Section -->
                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="20"/>
                                        <ColumnDefinition Width="*"/>
                                    </Grid.ColumnDefinitions>
                                    
                                    <!-- OS Updates -->
                                    <Border Grid.Column="0" Style="{StaticResource CardStyle}" Padding="20">
                                        <StackPanel>
                                            <TextBlock Text=" OS Updates" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnCheckOSUpdates" Content="Check for OS Updates" Style="{StaticResource ActionBtn}" Margin="0,0,0,15"/>
                                            <ScrollViewer Height="200" VerticalScrollBarVisibility="Auto">
                                                <TextBlock Name="txtOSUpdates" TextWrapping="Wrap" Foreground="{DynamicResource ThemeFg}" FontSize="12" Text="Click button to check for Windows updates..."/>
                                            </ScrollViewer>
                                        </StackPanel>
                                    </Border>
                                    
                                    <!-- App Updates -->
                                    <Border Grid.Column="2" Style="{StaticResource CardStyle}" Padding="20">
                                        <StackPanel>
                                            <TextBlock Text=" App Updates (Winget)" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,10"/>
                                            <Button Name="btnCheckAppUpdates" Content="Check for App Updates" Style="{StaticResource ActionBtn}" Margin="0,0,0,15"/>
                                            <ScrollViewer Height="200" VerticalScrollBarVisibility="Auto">
                                                <TextBlock Name="txtAppUpdates" TextWrapping="Wrap" Foreground="{DynamicResource ThemeFg}" FontSize="12" FontFamily="Consolas" Text="Click button to check for application updates via Winget..."/>
                                            </ScrollViewer>
                                        </StackPanel>
                                    </Border>
                                </Grid>
                                
                                <!-- Quick Settings -->
                                <Border Style="{StaticResource CardStyle}" Padding="20" Margin="0,20,0,0">
                                    <StackPanel>
                                        <TextBlock Text=" Quick Settings" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                        <Button Name="btnOpenWinUpdateSettings" Content=" Open Windows Update Settings" Width="300" Style="{StaticResource ActionBtn}"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                            <!-- 11. ISRAEL TV PANEL (Embedded) -->
                            <StackPanel Name="pnlIsraelTV" Visibility="Collapsed" Background="{DynamicResource ThemeBg}">
                                <!-- Header Row with Exit Button -->
                                <Grid Margin="0,0,0,15">
                                    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                    <TextBlock Name="lblTVTitle" Grid.Column="0" Text="Israel TV Hub" FontSize="28" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}"/>
                                    
                                    <!-- EXIT CINEMA BUTTON (Safe Location) -->
                                    <Button Name="btnExitCinema" Grid.Column="1" Content=" Exit Cinema Mode" Visibility="Collapsed" 
                                            Background="#CC0000" Foreground="White" FontWeight="Bold" Padding="15,5" BorderThickness="0" Cursor="Hand">
                                        <Button.Resources>
                                            <Style TargetType="Border"><Setter Property="CornerRadius" Value="5"/></Style>
                                        </Button.Resources>
                                    </Button>
                                </Grid>
                                
                                <Grid Name="grdIsraelTVContent" Height="650">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Name="colTVSidebar" Width="220"/> <!-- Channel List -->
                                        <ColumnDefinition Name="colTVSpacer" Width="10"/>  <!-- Spacer -->
                                        <ColumnDefinition Width="*"/>   <!-- Player Area -->
                                    </Grid.ColumnDefinitions>

                                    <!-- CHANNEL SELECTOR -->
                                    <Border Grid.Column="0" Name="brdChanList" Style="{StaticResource CardStyle}" Padding="10">
                                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                                            <StackPanel>
                                                <TextBlock Text="Live Channels" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,5"/>
                                                <Button Name="btnCh11" Content="Kan 11" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnCh12" Content="Keshet 12" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnCh13" Content="Reshet 13" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnCh14" Content="Now 14" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnCh23" Content="Kan 23 (Educational)" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnCh99" Content="Knesset Channel" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                
                                                <TextBlock Text="Radio Stations" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,15,0,5"/>
                                                <Button Name="btnRadGlz" Content="Galatz" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnRadGlglz" Content="Galgalatz" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnRadKan88" Content="Kan 88" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                <Button Name="btnRadReshetB" Content="Kan Reshet B" Style="{StaticResource ActionBtn}" Margin="0,2" HorizontalContentAlignment="Left" Padding="10,0"/>
                                                
                                                <Separator Background="{DynamicResource ThemeBorder}" Margin="0,15"/>
                                                <Button Name="btnCinemaMode" Content=" Cinema Mode" Background="#007ACC" Foreground="White" FontWeight="Bold" Margin="0,5" ToolTip="Maximize Player Area"/>
                                                <Button Name="btnLaunchExternal" Content=" Launch External Player" Background="#333333" Foreground="#AAAAAA"  FontSize="11" Margin="0,5" ToolTip="Open in separate window if player fails"/>
                                            </StackPanel>
                                        </ScrollViewer>
                                    </Border>

                                    <!-- PLAYER CONTAINER -->
                                    <Border Grid.Column="2" Style="{StaticResource CardStyle}" Padding="0" ClipToBounds="True">
                                        <Grid>
                                            <!-- Player Host (WebView2 injected here or external fallback) -->
                                            <Grid Name="pnlPlayerHost" Background="Black">
                                                <!-- Fallback message if separate window is used -->
                                                <TextBlock Name="lblExternalModeMsg" Text="Playing in external window..." HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#444" Visibility="Collapsed"/>
                                            </Grid>
                                             
                                            <!-- Overlay status text -->
                                            <Grid Name="lblTVStatus" Background="#111" IsHitTestVisible="False">
                                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                                    <TextBlock Text="&#xE7F4;" FontFamily="Segoe MDL2 Assets" Foreground="#555" FontSize="40" HorizontalAlignment="Center" Opacity="0.6"/>
                                                    <TextBlock Name="lblTVStatusText" Text="Select a channel to start watching" FontSize="16" Foreground="#888" Margin="0,10,0,0"/>
                                                </StackPanel>
                                            </Grid>
                                        </Grid>
                                    </Border>
                                </Grid>
                            </StackPanel>

                            <!-- 16. POWER PANEL (ADDED) -->
                            <StackPanel Name="pnlPower" Visibility="Collapsed">
                                <TextBlock Name="lblPowerHeader" Text="Power Options" FontSize="32" FontWeight="Bold" Foreground="{DynamicResource ThemeFg}" Margin="0,0,0,30"/>
                                
                                <WrapPanel HorizontalAlignment="Center">
                                    <Button Name="btnShutdown" Content=" Shutdown" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnRestart" Content=" Restart" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnSleep" Content=" Sleep" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnLock" Content=" Lock" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnSignOut" Content=" Sign Out" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                    <Button Name="btnHibernate" Content=" Hibernate" Width="200" Height="120" FontSize="20" Margin="10" Style="{StaticResource ActionBtn}"/>
                                </WrapPanel>
                                
                                <Border Style="{StaticResource CardStyle}" Margin="0,50,0,0" Padding="20" HorizontalAlignment="Center" Width="600">
                                    <StackPanel>
                                        <TextBlock Text="Advanced Power Options" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                        <WrapPanel HorizontalAlignment="Center">
                                            <Button Name="btnAbortShutdown" Content=" Abort Shutdown" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnAdvStartup" Content=" Advanced Startup" Width="180" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnUEFI" Content=" Boot to UEFI" Width="180" Style="{StaticResource ActionBtn}"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Style="{StaticResource CardStyle}" Margin="0,20,0,0" Padding="20" HorizontalAlignment="Center" Width="600">
                                    <StackPanel>
                                        <TextBlock Text="Remote Administration (LAN)" FlowDirection="LeftToRight" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource ThemeAccent}" Margin="0,0,0,15"/>
                                        <Grid Margin="0,0,0,10">
                                            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                            <TextBlock Text="Target IP / Hostname:" FlowDirection="LeftToRight" VerticalAlignment="Center" Foreground="{DynamicResource ThemeFg}" Margin="0,0,10,0"/>
                                            <TextBox Name="txtRemoteIP" Grid.Column="1" Height="30" VerticalContentAlignment="Center" Background="#99000000" Foreground="{DynamicResource ThemeFg}" BorderBrush="{DynamicResource ThemeBorder}" Padding="5"/>
                                        </Grid>
                                        <Grid Margin="0,0,0,15">
                                            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                            <TextBlock Text="Message (Optional):" FlowDirection="LeftToRight" VerticalAlignment="Center" Foreground="{DynamicResource ThemeFg}" Margin="0,0,24,0"/>
                                            <TextBox Name="txtRemoteMsg" Grid.Column="1" Height="30" VerticalContentAlignment="Center" Background="#99000000" Foreground="{DynamicResource ThemeFg}" BorderBrush="{DynamicResource ThemeBorder}" Padding="5"/>
                                        </Grid>
                                        <WrapPanel HorizontalAlignment="Center">
                                            <Button Name="btnRemoteMsg" Content=" Send Msg" Width="140" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnRemoteRestart" Content=" Remote Restart" Width="140" Style="{StaticResource ActionBtn}"/>
                                            <Button Name="btnRemoteShutdown" Content=" Remote Shutdown" Width="140" Style="{StaticResource ActionBtn}" Background="#800000"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                            </StackPanel>

                        </Grid>
                    </ScrollViewer>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@
